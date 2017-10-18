function [ gevin_score ] = gevinScoreCalculation( my_net, branch, respTable, genoTable, snp, zygo)
% 
% * Activation signature of a branch is defined as the upstream stimulations
%   that trigger the branch and the downstream genes regulated by the branch 
% 
% * A P-value is calculated for each of the genes downstream to a branch 
%   using a multivariate regression model:
%   - X - genotypic vector of a snp 
%   - Y - a multivariate transcriptional response of  the gene to all stims
%         upstream to the branch
% 
% * Fisher's combined probability test is then used to unify P-values of all
%   downsteam genes to a single score for a branch
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


num_stims = length(my_net.stims); 
num_branches = length(my_net.branches_list);

% // Find the activation signature of the branch:
[upstream_stims, downstream_genes] = findBranchActivationSignature(my_net, branch);

upstream_stims_idx = find(ismember(my_net.stims,upstream_stims));
downstream_genes_idx = find(ismember(respTable.Properties.RowNames,downstream_genes));

num_up_stims = length(upstream_stims);
num_down_genes = length(downstream_genes);



% // Define X = snp:
snp_vec = genoTable{snp,:};
num_indivs = length(snp_vec);
X = snp_vec';


idx = ~isnan(X);    % // remove NAN values
if zygo             % // remove genotype 2 if homozygous
    idx = idx & (X~=2); 
end
X = X(idx); 
X_dv = dummyvar(nominal(X));             
X_dv = X_dv(:,1:(end-1));


% // Define Y = response of a downstream gene to upstream stimulations:
genes_pvals = zeros(num_down_genes,1);

for g = 1:num_down_genes         % // pick only down genes
    gene = downstream_genes_idx(g);
    gene_exp = reshape(respTable{gene,:},num_indivs,num_stims);

    Y = gene_exp(:,upstream_stims_idx); % // pick only up stims
    Y = Y(idx,:); 
    
    
    % // Likelihood ratio test: with vs. without genetic effect
    X0 = ones(length(X),1);              
    X1 = [ones(length(X),1) X_dv];
    [~,~,~,~,logL0] = mvregress(X0,Y);
    [~,~,~,~,logL1] = mvregress(X1,Y);
    [~,genes_pvals(g)] = lratiotest(logL1,logL0,(rank(X1)-rank(X0))*num_up_stims);        
end


if isempty(genes_pvals)
    gevin_score = 1;
else
    gevin_score = fisherCombinedTest(genes_pvals);
end

% gevin_score = min(1,gevin_score*num_branches); % // bonferroni correction

end

