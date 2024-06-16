# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Json'
copyright = '2024, Dylan Hackers'
author = 'Dylan Hackers'
release = '1.1.1'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

import sys, os
sys.path.insert(0, os.path.abspath('../../_packages/sphinx-extensions/current/src/sphinxcontrib'))

import dylan.themes as dylan_themes
extensions = ['dylan.domain']

templates_path = ['_templates']
exclude_patterns = []

primary_domain = 'dylan'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'furo'
html_static_path = ['_static']

# Ignore certification verification
tls_verify = False
