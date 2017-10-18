function [ fisher_pval ] = fisherCombinedTest( pval_arr )
% 
% Combine results from several independent tests using the formula:
% -2 sum(ln p-vals) ~ chi-square
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

k = length(pval_arr);
ln_pvals = log(pval_arr);
sum_pvals = sum(ln_pvals(:));
fisher_statistic = -2*sum_pvals;

fisher_pval = chi2cdf(fisher_statistic,2*k,'upper');


end

