# Rollback Argo Cd App
#------------------------------------------------------
# 1. Disable Auto Sync
#------------------------------------------------------
argocd app set APPNAME [flags]
argocd app set my-app --sync-policy none
## Notes:
### • --sync-policy none → Disable Auto Sync
#------------------------------------------------------
## 2. Show History of App
#------------------------------------------------------
argocd app history APPNAME [flags]
argocd app history my-app
## Notes:
### • it shows only last 10 commits
#------------------------------------------------------
## 3. Rollback
#-----------------------------------------------------
argocd app rollback APPNAME [ID] [flags]
argocd app rollback my-app 
## Notes:
### • [ID] → Optional. 
###     • The revision ID (a sync history number or a commit hash) you want to roll back to.
###     • If you omit it, Argo CD will roll back to the previous revision by default.
### • --prune → Allow deleting unexpected resources
#------------------------------------------------------
