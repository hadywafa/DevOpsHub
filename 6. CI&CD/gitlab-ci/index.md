# GitLab CI Roadmap


I’d organize everything into **8 topics**, in this order:

1. **GitLab CI/CD Architecture & `.gitlab-ci.yml` Fundamentals**  
    Jobs, stages, pipelines, runners, executors, predefined variables, pipeline lifecycle.  
    Mapping: GitHub Actions workflow/job ↔ GitLab pipeline/job; Azure agent ↔ GitLab Runner.
    
2. **Pipeline Control: `workflow`, `rules`, Variables & Pipeline Sources**  
    Advanced `rules:if`, `changes`, `exists`, `workflow:rules`, MR vs branch vs tag vs scheduled/API/manual pipelines, variable precedence.  
    This is one of the most important GitLab-specific areas.
    
3. **DAG Pipelines, Dependencies, Artifacts & Caching**  
    `needs`, `needs:artifacts`, `needs:optional`, `dependencies`, `parallel`, `parallel:matrix`, artifacts, reports, cache keys/policies.  
    We’ll build pipelines that don’t unnecessarily wait for stages. GitLab supports advanced DAG relationships such as `needs:parallel:matrix` and cross-pipeline artifact retrieval. ([GitLab Docs](https://docs.gitlab.com/ci/yaml/?utm_source=chatgpt.com "CI/CD YAML syntax reference | GitLab Docs"))
    
4. **Reusable Pipelines & CI/CD Components**  
    `include`, templates, YAML anchors, `extends`, hidden jobs, `!reference`, `default`, component catalog, `spec:inputs`, reusable organization-wide pipelines.  
    I’ll compare this directly with **GitHub reusable workflows/composite actions** and **Azure DevOps templates**.
    
5. **Parent/Child & Multi-Project Pipelines**  
    Dynamic child pipelines, `trigger`, `strategy`, downstream pipelines, multi-project pipelines, passing variables/artifacts between pipelines, monorepo architecture.  
    This is where GitLab becomes especially powerful for platform engineering.
    
6. **GitLab Runners & Enterprise Runner Architecture**  
    Shell/Docker/Kubernetes executors, runner registration, tags, protected runners, shared/group/project runners, autoscaling, Kubernetes runner architecture, concurrency, security, troubleshooting and performance tuning.
    
7. **Deployments, Environments & GitOps**  
    Environments, deployments, review apps, dynamic environments, manual approvals, protected environments, deployment tiers, resource groups, concurrency control, Kubernetes integration and GitOps patterns.
    
8. **Security, Identity & Enterprise CI/CD Design**  
    Secrets/protected variables, `CI_JOB_TOKEN`, deploy tokens, OIDC / `id_tokens`, cloud federation, permissions, SAST/container/dependency scanning, compliance and **Pipeline Execution Policies** for centrally enforcing jobs across projects. GitLab currently recommends Pipeline Execution Policies for centralized enforcement rather than legacy compliance pipelines. ([GitLab Docs](https://docs.gitlab.com/user/application_security/policies/pipeline_execution_policies/?utm_source=chatgpt.com "Pipeline execution policies | GitLab Docs"))
    

After these 8 topics, you should be able to **design GitLab CI/CD architecture**, not merely write `.gitlab-ci.yml`.


