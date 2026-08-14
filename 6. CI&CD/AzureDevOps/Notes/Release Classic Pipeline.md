

Good. Now that your deployment works, the main thing is to build the **correct mental model**. Classic Release becomes much easier once you stop treating every `$(something)` as the same kind of variable.

I’ll focus specifically on **Azure DevOps Classic Release pipelines**, because Classic Build has some different concepts. In particular, **Classic process parameters do not exist in Classic Release**; the “parameters” you are using are **Task Group parameters**, which are a different thing. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/parameters?view=azure-devops "Classic process parameters - Azure Pipelines | Microsoft Learn"))

# 1. The whole Classic Release model

Think of it like this:

```text
                    Azure DevOps Project
                           │
              ┌────────────┴────────────┐
              │                         │
          Library                 Release Definition
     Variable Groups                    │
              │                         │
              └──────────────┐          │
                             ▼          ▼
                          Release Instance
                               │
               ┌───────────────┼───────────────┐
               ▼               ▼               ▼
              DEV             UAT             PROD
             Stage           Stage            Stage
               │               │               │
            Agent Job       Agent Job       Agent Job
               │
        ┌──────┼──────────┐
        ▼      ▼          ▼
      Task   Task Group   Task
               │
        ┌──────┼──────┐
        ▼      ▼      ▼
      Bash    Bash    Bash
      Task    Task    Task
               │
               ▼
          your .sh file
```

A Classic Release pipeline consumes one or more artifacts and defines how those artifacts are deployed through stages such as DEV/UAT/PROD. A **release** is a snapshot of the artifacts plus the release definition at that moment; a **deployment** is the execution of one stage of that release. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?view=azure-devops&utm_source=chatgpt.com "Key Azure Pipelines concepts"))

A stage contains jobs, and jobs contain tasks. A task is the smallest packaged unit of execution, such as Bash, PowerShell, Copy Files, Helm, Azure CLI, etc. Tasks within an agent job run on an agent. Multiple jobs in a Classic Release execute sequentially, and a later job might execute on a different agent, so you should never rely on local process/filesystem state automatically surviving between jobs. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/phases?view=azure-devops&utm_source=chatgpt.com "Jobs in Azure Pipelines"))

---

# 2. There are several different things called “variables”

This is where most confusion comes from.

You should mentally separate these:

|Thing|Example|Owned by|Purpose|
|---|---|---|---|
|Library variable|`OPENSHIFT_TOKEN_UAT`|Azure DevOps Library|Central config/secrets|
|Release variable|`APP_NAME`|Release definition|Shared across stages|
|Stage variable|`NAMESPACE`|One stage|Environment-specific value|
|Predefined variable|`Release.ReleaseId`|Azure DevOps|Runtime context|
|Task Group parameter|`P3_OPENSHIFT_TOKEN`|Task Group|Configure reusable task|
|Pipeline runtime variable|`IMAGE_TAG`|Agent/pipeline runtime|Created during deployment|
|Bash environment variable|`$OPENSHIFT_TOKEN`|Bash process|Used by `.sh`|
|Bash local variable|`token="$1"`|Script process|Normal shell variable|

These are **not interchangeable**.

That one distinction explains almost every issue you just had.

---

# 3. Library Variable Groups

A Variable Group is simply a centralized dictionary:

```text
Variable Group: openshift-uat

OPENSHIFT_API_ENDPOINT = https://api.ocp.example.com:6443
OPENSHIFT_TOKEN_UAT     = ********
GITHUB_PAT              = ********
REPOSITORY_URL          = ...
```

Variable Groups live in:

```text
Pipelines
  └─ Library
      └─ Variable Groups
```

They can contain normal variables and secret variables. Marking a variable secret causes Azure DevOps to store it securely and mask its value in logs where possible. Variable Groups can then be linked to Classic pipelines/stages, and changes to the group become available to linked definitions/stages. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops "Manage variable groups - Azure Pipelines | Microsoft Learn"))

The important point is:

> The Variable Group is storage. It is not a Bash environment file.

When you link it to UAT, you are effectively telling Azure DevOps:

```text
For this deployment context,
make these pipeline variables available.
```

Azure DevOps then handles the values while preparing tasks.

---

# 4. Release-scoped vs Stage-scoped variables

Classic Release gives you another variable layer under the **Variables** tab.

You can define:

```text
NAME                    VALUE                SCOPE

APPLICATION_NAME        billing-service      Release
OPENSHIFT_NAMESPACE     billing-uat          UAT
OPENSHIFT_NAMESPACE     billing-prod         PROD
```

Release-scoped values are intended to be used across all stages, while stage-scoped values are intended for environment-specific settings. Microsoft explicitly documents Variable Groups, release variables, and stage variables as the primary scopes available in Classic Release. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/variables?view=azure-devops "Use variables in Classic release pipelines - Azure Pipelines | Microsoft Learn"))

A sensible architecture is therefore:

```text
Library
────────────────────────────────
GITHUB_PAT
SONAR_TOKEN
NEXUS_PASSWORD


Release scope
────────────────────────────────
APPLICATION_NAME
GITHUB_ORG
SCRIPT_REPOSITORY


DEV stage
────────────────────────────────
OPENSHIFT_API_ENDPOINT
OPENSHIFT_NAMESPACE


UAT stage
────────────────────────────────
OPENSHIFT_API_ENDPOINT
OPENSHIFT_NAMESPACE


PROD stage
────────────────────────────────
OPENSHIFT_API_ENDPOINT
OPENSHIFT_NAMESPACE
```

That separation is much cleaner than encoding everything as:

```text
OPENSHIFT_API_ENDPOINT_DEV
OPENSHIFT_API_ENDPOINT_UAT
OPENSHIFT_API_ENDPOINT_PROD
```

when the Classic Release stage itself can represent the environment.

---

# 5. `$(VARIABLE)` is Azure DevOps syntax

This one is extremely important.

When you write:

```text
$(OPENSHIFT_TOKEN_UAT)
```

that syntax belongs to **Azure DevOps**, not Bash.

It means:

```text
Azure DevOps:
"Before executing this task, replace this macro
with the current value of OPENSHIFT_TOKEN_UAT."
```

Macro variables are expanded at runtime before a task executes. If Azure DevOps cannot resolve the variable, macro syntax can remain unchanged as the literal string:

```text
$(OPENSHIFT_TOKEN_UAT)
```

That exact behavior explains the problem you saw earlier. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops "Define variables - Azure Pipelines | Microsoft Learn"))

So:

```text
$(NAME)
```

means:

```text
ADO variable macro
```

while:

```bash
$NAME
```

or:

```bash
${NAME}
```

means:

```text
Bash environment/shell variable
```

These are completely different expansion engines.

---

# 6. Be especially careful because Bash also understands `$()`

Bash has its own syntax:

```bash
$(command)
```

which means **command substitution**.

For example:

```bash
CURRENT_DATE=$(date)
```

means:

```text
execute `date`
and put its output into CURRENT_DATE
```

Therefore, this is dangerous inside an actual `.sh` file:

```bash
echo "$(OPENSHIFT_TOKEN)"
```

If Azure DevOps fails to expand it before Bash receives the script, Bash can interpret:

```bash
$(OPENSHIFT_TOKEN)
```

as:

```text
execute a command named OPENSHIFT_TOKEN
```

So your source `.sh` files ideally should know **nothing about Azure DevOps syntax**.

Good:

```bash
echo "$OPENSHIFT_API_ENDPOINT"
```

Good:

```bash
OPENSHIFT_API_ENDPOINT="$1"
```

Avoid putting this directly in reusable `.sh` source:

```bash
echo "$(OPENSHIFT_API_ENDPOINT)"
```

That keeps your scripts portable outside ADO too.

---

# 7. What exactly is a Task Group?

A Task Group is basically the Classic-pipeline equivalent of a reusable function/template.

Imagine you originally have:

```text
Task 1: Checkout scripts
Task 2: Validate parameters
Task 3: Validate OpenShift connection
Task 4: Deploy
Task 5: Verify
```

You select those tasks and create:

```text
Task Group:
OpenShift Deploy
```

Now many release pipelines can use:

```text
OpenShift Deploy
```

rather than copying all five tasks.

Task Groups are stored at the project level and can be reused by Classic pipelines in that project. Changes to a Task Group are centrally reflected in definitions using it, and Task Groups support versioning so you can introduce a new version rather than immediately changing every consumer. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/task-groups?view=azure-devops "Task groups in Classic pipelines - Azure Pipelines | Microsoft Learn"))

Conceptually:

```text
Task Group = function
```

For example:

```text
OpenShiftDeploy(
    environment,
    apiEndpoint,
    token,
    githubPat
)
```

Your release pipeline calls the function:

```text
OpenShiftDeploy(
    qa,
    $(OPENSHIFT_API_ENDPOINT_UAT),
    $(OPENSHIFT_TOKEN_UAT),
    $(GITHUB_PAT)
)
```

That is the correct mental model.

---

# 8. Task Group parameters are NOT pipeline variables

This is the distinction that caused your problem.

Your Task Group contains parameters:

```text
P1_ENVIRONMENT
P2_OPENSHIFT_API_ENDPOINT
P3_OPENSHIFT_TOKEN
P4_GITHUB_PAT
```

They are essentially **inputs to the Task Group**.

Microsoft describes the process like this: when a Task Group is created, variables referenced in underlying task inputs can be extracted into Task Group parameters. At runtime, Azure DevOps expands the Task Group and applies the values supplied to those underlying task inputs. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/task-groups?view=azure-devops "Task groups in Classic pipelines - Azure Pipelines | Microsoft Learn"))

So don't think:

```text
P3_OPENSHIFT_TOKEN
        =
global ADO variable
```

Think:

```text
P3_OPENSHIFT_TOKEN
        =
argument to the OpenShiftDeploy reusable component
```

That's much closer to reality.

---

# 9. How your current working pipeline actually behaves

You now have something like:

```text
Library:

OPENSHIFT_TOKEN_UAT
    =
secret-abc
```

Your Classic Release calls:

```text
Task Group: OpenShift Deploy

environment
    qa

OPENSHIFT_API_ENDPOINT
    $(OPENSHIFT_API_ENDPOINT_UAT)

OPENSHIFT_TOKEN
    $(OPENSHIFT_TOKEN_UAT)

GITHUB_PAT
    $(GITHUB_PAT)
```

So before execution:

```text
$(OPENSHIFT_TOKEN_UAT)
        ↓ ADO macro expansion
secret-abc
```

That value becomes the Task Group input.

Inside the Task Group you now use:

```text
Bash Task

Arguments:

"$(P1_ENVIRONMENT)"
"$(P2_OPENSHIFT_API_ENDPOINT)"
"$(P3_OPENSHIFT_TOKEN)"
"$(P4_GITHUB_PAT)"
```

The Task Group expands its parameter into the Bash task input:

```text
Arguments:

"qa"
"https://openshift..."
"secret-abc"
"github-secret"
```

Then Bash starts your script:

```bash
deploy.sh \
    "qa" \
    "https://openshift..." \
    "secret-abc" \
    "github-secret"
```

And Bash sees:

```bash
$1 = qa
$2 = https://openshift...
$3 = secret-abc
$4 = github-secret
```

Therefore your script does:

```bash
CIM_CD_ENV="$1"
OPENSHIFT_API_ENDPOINT="$2"
OPENSHIFT_TOKEN="$3"
GITHUB_PAT="$4"
```

That is the full movement:

```text
Library variable
        ↓
ADO pipeline variable
        ↓
$(...) macro expansion
        ↓
Task Group input
        ↓
Task input
        ↓
Bash argument
        ↓
$1 / $2 / $3
        ↓
shell variable
```

And that's why your current solution works.

---

# 10. Why your previous environment-variable approach failed

You had:

```text
Task Group parameter:
P3_OPENSHIFT_TOKEN
```

and then inside the Bash task:

```text
Environment Variables:

OPENSHIFT_TOKEN = $(P3_OPENSHIFT_TOKEN)
```

But the value reaching Bash was:

```text
OPENSHIFT_TOKEN=$(P3_OPENSHIFT_TOKEN)
```

rather than:

```text
OPENSHIFT_TOKEN=actual-token
```

So Bash received a perfectly valid environment variable whose **value happened to be the literal string**:

```text
$(P3_OPENSHIFT_TOKEN)
```

Then:

```bash
echo "$OPENSHIFT_TOKEN"
```

correctly printed:

```text
$(P3_OPENSHIFT_TOKEN)
```

The Bash side was not broken. The expansion before Bash was the part that didn't occur.

This class of behavior has been reported in Microsoft's `azure-pipelines-tasks` repository for Task Group parameter mappings; passing the Task Group input as an actual script/task argument is one documented workaround pattern. ([GitHub](https://github.com/microsoft/azure-pipelines-tasks/issues/13066?utm_source=chatgpt.com "Inline scripts can't read task group parameters. · Issue # ..."))

---

# 11. Environment variables are another boundary

Suppose Azure DevOps has:

```text
MY_URL=https://example.com
```

A task process may receive a corresponding environment variable.

On Linux:

```bash
echo "$MY_URL"
```

For variables whose names contain dots/spaces, Azure DevOps transforms names when exposing them to the environment. For example:

```text
Agent.WorkFolder
```

becomes:

```bash
$AGENT_WORKFOLDER
```

Microsoft documents the conversion as uppercase with dots/spaces changed to underscores. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/variables?view=azure-devops "Use variables in Classic release pipelines - Azure Pipelines | Microsoft Learn"))

So:

```text
ADO variable
my.application.url
```

roughly maps to:

```bash
$MY_APPLICATION_URL
```

when it is injected into the process environment.

---

# 12. Secrets behave differently

Normal values and secret values are intentionally treated differently.

A normal value can commonly be exposed to scripts as an environment variable.

A secret variable is **not automatically mapped into the script environment**. Microsoft recommends explicitly mapping secrets to task environment variables. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/bash-v3?view=azure-pipelines "Bash@3 - Bash v3 task | Microsoft Learn"))

For example, without your Task Group problem, the preferred model would normally be:

```text
Task environment:

OPENSHIFT_TOKEN = $(OPENSHIFT_TOKEN)
```

then:

```bash
echo "${OPENSHIFT_TOKEN:+TOKEN PRESENT}"
```

The problem in your specific Task Group was that the parameter-to-environment mapping itself was what failed, so passing it through Bash arguments worked around that Task Group behavior.

There is one security tradeoff worth knowing: Microsoft's current logging/security guidance recommends **not passing secrets on command lines**, because command-line arguments may be visible to other processes or OS auditing. Environment mapping is preferable when possible. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands?view=azure-devops "Logging commands - Azure Pipelines | Microsoft Learn"))

So your current workaround:

```text
$(P3_OPENSHIFT_TOKEN)
        ↓
script argument
        ↓
$3
```

works, but for highly sensitive production credentials on a shared self-hosted agent, a custom task or a design that allows proper secret environment mapping would be cleaner long term.

And definitely never do:

```bash
set -x
```

around secrets.

Nor:

```bash
echo "$OPENSHIFT_TOKEN"
```

Nor:

```bash
echo "$@"
```

---

# 13. Shell variables do NOT survive between Bash tasks

Another crucial concept.

Imagine Task 1:

```bash
MY_VALUE="hello"
export MY_VALUE
```

Then Task 1 finishes.

Task 2:

```bash
echo "$MY_VALUE"
```

Do **not** expect Task 2 to receive it.

Why?

Because effectively:

```text
Task 1
   ↓
bash process A
   ↓
process exits
```

then:

```text
Task 2
   ↓
bash process B
```

`export` only propagates environment variables from a process to its **child processes**. It does not update Azure DevOps.

This is why your original `Define Parameters` task wasn't useful:

```bash
OPENSHIFT_TOKEN=...
GITHUB_PAT=...
```

Those were just shell variables in that Bash process.

---

# 14. `##vso[task.setvariable]` is how a script talks back to ADO

If Task 1 calculates something that Task 2 needs, you need to tell the Azure Pipelines agent about it.

Example:

```bash
IMAGE_TAG="2026-08-14.1234"

echo "##vso[task.setvariable variable=IMAGE_TAG]$IMAGE_TAG"
```

Azure DevOps agents monitor stdout for special logging commands beginning with:

```text
##vso[...]
```

and interpret them as instructions. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands?view=azure-devops "Logging commands - Azure Pipelines | Microsoft Learn"))

So:

```text
Task 1
   │
   ├─ calculate IMAGE_TAG
   │
   └─ echo ##vso[task.setvariable...]
              │
              ▼
       Azure DevOps Agent
              │
              ▼
        pipeline variable
              │
              ▼
           Task 2
```

Task 2 can then use:

```text
$(IMAGE_TAG)
```

or, where environment injection applies:

```bash
$IMAGE_TAG
```

Variables created using `task.setvariable` become available to subsequent tasks in the same job; they are not available earlier in the task that creates them, and Classic Release documentation describes script-set variables as job-scoped rather than persistent across jobs/stages. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-variables-scripts?view=azure-devops "Set variables in scripts - Azure Pipelines | Microsoft Learn"))

---

# 15. So there are three completely different ways data gets into a `.sh`

This is the part I want you to remember.

### ADO macro → script argument

ADO:

```text
Arguments:
"$(MY_VARIABLE)"
```

Script:

```bash
VALUE="$1"
```

Flow:

```text
ADO variable
→ task input
→ process argument
→ $1
```

This is what you are currently using successfully.

### ADO variable → environment variable

Task:

```text
Environment Variables

MY_VAR = $(MY_VARIABLE)
```

Script:

```bash
echo "$MY_VAR"
```

Flow:

```text
ADO variable
→ process environment
→ $MY_VAR
```

This is normally especially useful for secrets, although your Task Group parameter mapping hit the Classic Task Group issue. Microsoft explicitly supports environment mapping in Bash tasks. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/bash-v3?view=azure-pipelines "Bash@3 - Bash v3 task | Microsoft Learn"))

### Task 1 → ADO → Task 2

Task 1:

```bash
VALUE="123"

echo "##vso[task.setvariable variable=VALUE]$VALUE"
```

Task 2:

```text
Arguments:
"$(VALUE)"
```

Flow:

```text
Task 1 shell
→ ##vso logging command
→ ADO runtime variable
→ Task 2 input
```

That's the mechanism for calculated values.

---

# 16. Do not confuse Task Group parameters with Classic Process Parameters

There are unfortunately two things called parameters.

**Classic Build pipeline process parameters** are UI-level parameters that can expose task settings centrally and can support richer controls such as dropdowns and checkboxes. Microsoft explicitly states that these process parameters are **not available in Classic Release pipelines**. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/parameters?view=azure-devops "Classic process parameters - Azure Pipelines | Microsoft Learn"))

Your:

```text
P1_ENVIRONMENT
P2_OPENSHIFT_API_ENDPOINT
P3_OPENSHIFT_TOKEN
P4_GITHUB_PAT
```

are therefore:

```text
Task Group parameters
```

not:

```text
Classic process parameters
```

That's an important vocabulary distinction.

---

# 17. Why Task Groups automatically created those P1/P2/P3 values

When you create a Task Group from existing tasks, Azure DevOps examines the task inputs.

If it sees references like:

```text
$(environment)
$(OPENSHIFT_API_ENDPOINT)
$(OPENSHIFT_TOKEN)
```

it can extract those values and expose them as Task Group parameters.

Microsoft describes this explicitly: variables in encapsulated tasks are automatically extracted into configurable Task Group parameters, except predefined variables. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/task-groups?view=azure-devops "Task groups in Classic pipelines - Azure Pipelines | Microsoft Learn"))

So the transformation is conceptually:

```text
Before Task Group:

Bash
  Arguments:
    "$(environment)"
    "$(OPENSHIFT_TOKEN)"
```

becomes:

```text
Task Group:

Parameters:
    environment
    OPENSHIFT_TOKEN

Internal Bash:
    Arguments:
      "$(environment)"
      "$(OPENSHIFT_TOKEN)"
```

Now whoever consumes the Task Group provides those inputs.

---

# 18. Task Group parameters should describe the interface

Try to treat the Task Group like code.

Instead of arbitrary generated names:

```text
P1_ENVIRONMENT
P2_OPENSHIFT_API_ENDPOINT
P3_OPENSHIFT_TOKEN
P4_GITHUB_PAT
```

I'd eventually clean them up to:

```text
environment
openshiftApiEndpoint
openshiftToken
githubPat
```

Then the Task Group interface becomes obvious:

```text
OpenShift Deploy

environment:              qa
openshiftApiEndpoint:     $(OPENSHIFT_API_ENDPOINT_UAT)
openshiftToken:           $(OPENSHIFT_TOKEN_UAT)
githubPat:                $(GITHUB_PAT)
```

Internally:

```text
Deploy Script

Arguments:

"$(environment)"
"$(openshiftApiEndpoint)"
"$(openshiftToken)"
```

Much easier to maintain.

---

# 19. Don't parameterize everything

Suppose every OpenShift deployment always runs:

```text
bash
failOnStderr=false
workingDirectory=$(System.DefaultWorkingDirectory)
```

Those don't necessarily need to become Task Group parameters.

Expose only things the caller is supposed to change.

Think about a function:

```python
deploy(
    environment,
    endpoint,
    token
)
```

You wouldn't create:

```python
deploy(
    bashVersion,
    taskVersion,
    failOnStderr,
    bashWorkingDirectory,
    scriptEncoding,
    ...
)
```

unless callers really need to configure them.

Task Group parameters should define the **public interface**.

Everything else should remain an implementation detail.

---

# 20. Variable Groups should contain data, Task Groups should contain behavior

This is a very useful design rule.

```text
Variable Group
===============
DATA / CONFIGURATION

URLs
tokens
passwords
tenant IDs
registry names
cluster endpoints
```

while:

```text
Task Group
===============
BEHAVIOR

login
checkout
validate
deploy
verify
rollback
```

Therefore:

```text
Library:
    "what values should I use?"

Task Group:
    "what steps should I perform?"
```

That separation produces maintainable Classic pipelines.

---

# 21. Your OpenShift deployment should ideally look like this

At the top:

```text
Library Variable Group
────────────────────────────

GITHUB_PAT              secret
OPENSHIFT_TOKEN_UAT     secret
OPENSHIFT_ENDPOINT_UAT  config
```

Classic Release:

```text
             OpenShift Deployment
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
         DEV         UAT         PROD
          │           │           │
          └───────────┼───────────┘
                      ▼
               OpenShift Deploy
                 Task Group
```

For UAT:

```text
environment
    uat

openshiftApiEndpoint
    $(OPENSHIFT_ENDPOINT_UAT)

openshiftToken
    $(OPENSHIFT_TOKEN_UAT)

githubPat
    $(GITHUB_PAT)
```

Task Group:

```text
Git Repo Fetch
        ↓
Validate Scripts
        ↓
Validate OpenShift
        ↓
Deploy
        ↓
Verify
```

Then each actual `.sh` receives only what it needs.

For example:

```text
validate.sh:

Arguments:
"$(environment)"
"$(openshiftApiEndpoint)"
```

```bash
#!/bin/bash
set -euo pipefail

ENVIRONMENT="$1"
OPENSHIFT_API_ENDPOINT="$2"
```

And:

```text
deploy.sh:

Arguments:
"$(environment)"
"$(openshiftApiEndpoint)"
"$(openshiftToken)"
```

```bash
#!/bin/bash
set -euo pipefail

ENVIRONMENT="$1"
OPENSHIFT_API_ENDPOINT="$2"
OPENSHIFT_TOKEN="$3"
```

That makes each script's contract explicit.

---

# 22. A good rule for `.sh` files

Your `.sh` files should ideally be unaware that Azure DevOps exists.

For example:

```bash
#!/bin/bash
set -euo pipefail

ENVIRONMENT="$1"
API_ENDPOINT="$2"
TOKEN="$3"

oc login "$API_ENDPOINT" --token="$TOKEN"

./deploy-application.sh "$ENVIRONMENT"
```

Then you could manually execute it:

```bash
./deploy.sh \
    uat \
    https://api.example.com:6443 \
    my-token
```

or ADO could execute it.

That separation gives you:

```text
Azure DevOps
    = orchestration

Task Group
    = reusable deployment workflow

.sh
    = deployment implementation
```

This is much cleaner than embedding ADO syntax throughout every script.

---

# 23. Task Group versioning matters

Your screenshot showed:

```text
OpenShift Deploy
Version 1.*
```

Task Groups support versioning. Microsoft recommends using versioning when you want to develop changes without instantly forcing existing pipelines onto a new implementation. You can save changes as a draft, test them, and then publish a new version; pipelines can select an earlier or newer version. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/task-groups?view=azure-devops "Task groups in Classic pipelines - Azure Pipelines | Microsoft Learn"))

For something used by many application teams, I'd treat versions roughly like:

```text
OpenShift Deploy 1.x
    Existing stable implementation

OpenShift Deploy 2.x
    New deployment design
```

instead of repeatedly making breaking changes to `1.x`.

---

# 24. Release instances are snapshots

Another useful Classic concept.

Suppose today you have:

```text
Release Definition:
OpenShift Deploy 1.x
```

and create:

```text
Release-245
```

A Classic Release represents a versioned snapshot of the artifacts and relevant release definition information needed for execution. Later edits to the definition apply to future release behavior rather than changing history into something entirely different. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?view=azure-devops&utm_source=chatgpt.com "Key Azure Pipelines concepts"))

That's why you should distinguish:

```text
Release Definition
```

from:

```text
Release-245
```

The first is the template.

The second is an execution instance.

---

# 25. Predefined variables

ADO also gives you variables automatically.

Examples include things representing:

```text
Release
Agent
System
Artifact
Stage/environment
```

For example, Classic Release predefined variables can provide artifact information, release IDs, stage information and agent context. They can be used as task inputs using `$(...)`, and when exposed to scripts their names are normalized into environment-variable form. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/variables?view=azure-devops&utm_source=chatgpt.com "Use variables in Classic release pipelines - Azure"))

For example:

```text
$(Release.ReleaseId)
```

versus Bash environment form roughly:

```bash
$RELEASE_RELEASEID
```

This is why you often don't need to manually pass things such as release IDs or artifact metadata.

---

# 26. Debugging variable problems systematically

Whenever a variable isn't working, don't randomly change syntax.

Follow one chain:

```text
SOURCE
  ↓
ADO VARIABLE
  ↓
TASK GROUP PARAMETER
  ↓
TASK INPUT
  ↓
PROCESS ARGUMENT / ENV
  ↓
SCRIPT
```

Ask at every boundary:

```text
Does the value exist here?
```

For example:

```text
Library:
OPENSHIFT_API_ENDPOINT_UAT
✓
```

then:

```text
Task Group invocation:
$(OPENSHIFT_API_ENDPOINT_UAT)
✓
```

then:

```text
Task Group parameter:
openshiftApiEndpoint
✓
```

then:

```text
Bash Arguments:
$(openshiftApiEndpoint)
✓
```

then script:

```bash
echo "API=${1}"
✓
```

For secrets don't print them. Check only existence:

```bash
if [[ -n "${TOKEN:-}" ]]; then
    echo "TOKEN PRESENT"
else
    echo "TOKEN MISSING"
fi
```

Classic Release also supports `System.Debug=true`, which causes additional diagnostic information to appear, and the Initialize Job log can show the variables available to that job. ([Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/variables?view=azure-devops "Use variables in Classic release pipelines - Azure Pipelines | Microsoft Learn"))

---

# 27. The four syntaxes I want you to memorize

This is probably the most useful part of the entire explanation.

```text
$(NAME)
```

means:

```text
Azure DevOps variable/task-group macro
```

---

```bash
$NAME
${NAME}
```

means:

```text
Bash variable/environment variable
```

---

```bash
$1
$2
$3
```

means:

```text
Bash positional arguments
```

---

```bash
echo "##vso[task.setvariable variable=NAME]value"
```

means:

```text
Bash → Azure DevOps
create/update a runtime pipeline variable
```

So mentally:

```text
ADO → Task
      $(VAR)

Task → Bash arguments
      $1 $2 $3

Environment → Bash
      $VAR

Bash → ADO
      ##vso[task.setvariable ...]
```

If you remember that, you'll solve probably 90% of Classic pipeline variable problems yourself.

---

# 28. Final mental model for your exact setup

This is the diagram I'd keep as your reference:

```text
                    AZURE DEVOPS
                         │
                         │
                Library Variable Group
                         │
             ┌───────────┴───────────┐
             │                       │
        normal config             secrets
             │                       │
             └──────────┬────────────┘
                        │
                        ▼
              Classic Release Stage
                        │
              $(LIBRARY_VARIABLE)
                        │
                        ▼
                Task Group Input
              openshiftToken = ...
                        │
                        ▼
                Internal Bash Task
                        │
                  Arguments field
                        │
            "$(openshiftToken)"
                        │
                        ▼
               Linux process starts
                        │
              deploy.sh arg1 arg2
                        │
                        ▼
                     Bash
                        │
                    $1 / $2
                        │
                        ▼
              local shell variables
                        │
                        ▼
                  oc / helm / git
```

And in the opposite direction:

```text
oc / script calculates value
             │
             ▼
          Bash value
             │
             ▼
##vso[task.setvariable variable=IMAGE_TAG]...
             │
             ▼
       Azure DevOps Agent
             │
             ▼
        $(IMAGE_TAG)
             │
             ▼
      subsequent task
```

The single sentence version is:

> **Library/Release variables are data managed by ADO; Task Group parameters are inputs to a reusable workflow; task inputs transport those values into a process; `$1`/`$VAR` are what Bash understands; and `##vso` is how Bash sends information back to ADO.**

Once you keep those layers separate, Classic Release stops feeling magical and starts behaving like a normal orchestration system.