#!/bin/bash

# Install JupyterLab extension
jupyter labextension install @jupyterlab/toc

# see https://ipywidgets.readthedocs.io/en/latest/user_install.html
# conda environment?
# conda install -c conda-forge nodejs

# see example at: https://github.com/binder-examples/jupyter-extension/blob/master/postBuild
# see https://jupyter-contrib-nbextensions.readthedocs.io/en/latest/
jupyter contrib nbextension install --user
jupyter nbextension enable --py widgetsnbextension
jupyter labextension install @jupyter-widgets/jupyterlab-manager

# see example at: https://github.com/binder-examples/r_with_python/blob/master/binder/postBuild
# Remove output from Jupyter notebooks
#jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace index.ipynb

# Import the workspace into JupyterLab
#jupyter lab workspaces import .binder/workspace.json
