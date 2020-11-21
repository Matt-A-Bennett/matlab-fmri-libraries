close all
clear all
run estimate_pRFs_wrap.m
dbquit

clear test
run Fit2dGaussian

fitted_models = fit_pRFs(multi_func_ni, combined_models, fit_pRFs_params);
