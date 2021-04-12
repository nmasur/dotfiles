" Snippets
"---------

" Basic programming files
nnoremap ,sh :-1read $DOTS/shell/templates/skeleton.sh<CR>Gdd03kC
nnoremap ,py :-1read $DOTS/shell/templates/skeleton.py<CR>Gdd08kC

" Kubernetes
nnoremap ,cm :-1read $DOTS/shell/templates/configmap.yaml<CR>Gdd0gg
nnoremap ,sec :-1read $DOTS/shell/templates/secret.yaml<CR>Gdd0gg
nnoremap ,dep :-1read $DOTS/shell/templates/deployment.yaml<CR>Gdd0gg
nnoremap ,svc :-1read $DOTS/shell/templates/service.yaml<CR>Gdd0gg
nnoremap ,cro :-1read $DOTS/shell/templates/clusterrole.yaml<CR>Gdd0gg
nnoremap ,crb :-1read $DOTS/shell/templates/clusterrolebinding.yaml<CR>Gdd0gg
nnoremap ,ro :-1read $DOTS/shell/templates/role.yaml<CR>Gdd0gg
nnoremap ,rb :-1read $DOTS/shell/templates/rolebinding.yaml<CR>Gdd0gg
nnoremap ,sa :-1read $DOTS/shell/templates/serviceaccount.yaml<CR>Gdd0gg
