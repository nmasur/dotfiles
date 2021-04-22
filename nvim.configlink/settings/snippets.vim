" Snippets
"---------

" Basic programming files
nnoremap ,sh :-1read $DOTS/templates/programs/skeleton.sh<CR>Gdd03kC
nnoremap ,py :-1read $DOTS/templates/programs/skeleton.py<CR>Gdd08kC

" Kubernetes
nnoremap ,cm :-1read $DOTS/templates/kubernetes/configmap.yaml<CR>Gdd0gg
nnoremap ,sec :-1read $DOTS/templates/kubernetes/secret.yaml<CR>Gdd0gg
nnoremap ,dep :-1read $DOTS/templates/kubernetes/deployment.yaml<CR>Gdd0gg
nnoremap ,svc :-1read $DOTS/templates/kubernetes/service.yaml<CR>Gdd0gg
nnoremap ,ing :-1read $DOTS/templates/kubernetes/ingress.yaml<CR>Gdd0gg
nnoremap ,cro :-1read $DOTS/templates/kubernetes/clusterrole.yaml<CR>Gdd0gg
nnoremap ,crb :-1read $DOTS/templates/kubernetes/clusterrolebinding.yaml<CR>Gdd0gg
nnoremap ,ro :-1read $DOTS/templates/kubernetes/role.yaml<CR>Gdd0gg
nnoremap ,rb :-1read $DOTS/templates/kubernetes/rolebinding.yaml<CR>Gdd0gg
nnoremap ,sa :-1read $DOTS/templates/kubernetes/serviceaccount.yaml<CR>Gdd0gg
