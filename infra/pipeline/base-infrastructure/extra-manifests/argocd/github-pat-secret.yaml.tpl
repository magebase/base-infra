apiVersion: v1
kind: Secret
metadata:
  name: github-pat-creds-site
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: https://github.com/magebase/site.git
  username: ekrata-main
  password: ${ARGOCD_REPO_TOKEN}
---
apiVersion: v1
kind: Secret
metadata:
  name: github-pat-creds-genfix
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: https://github.com/magebase/genfix.git
  username: ekrata-main
  password: ${ARGOCD_REPO_TOKEN}
