function [ ] = MainGevinAlgorithm( output_file, net_name, response_files, genotype_file, zygosity)

% % % % % % % % % % % % % % % % 

% For DEBUG use:
if nargin==0
   net_name = 'BxdTlrNet'; 
   
   genotype_file = 'genotypes.xls';

   response_files = {'response_pam.xls','response_lps.xls','response_poly.xls'};
   
   output_file = ['output files\' net_name '_output.xls'];
   
   zygosity = 'homo';
%    zygosity = 'hetero';

end
% % % % % % % % % % % % % % % % 

tic

disp('Start...');

if nargin == 6 || nargin == 0
    disp('Calculate GEVIN scores for all SNPs');
else
    error('Problem with input variables');
end


if strcmp(zygosity,'homo')
    zygo=true;
elseif strcmp(zygosity,'hetero')
    zygo=false;
else
    error('Invalid zygosity type');
end


% // (1) Load network:
load(net_name); 
num_branches = length(my_net.branches_list);
num_stims = length(my_net.stims);
num_genes = length(my_net.genes);

% // (2) Load expression response files:
genoTable = readtable(genotype_file,'ReadRowNames',true);
num_indivs = size(genoTable,2);
num_snps = size(genoTable,1);


% // (3) Load transcriptional response files for each stimulation:
if num_stims ~= length(response_files);
    error('Number of response files do not match the number of stimulations in the network');
end
respTable = array2table(zeros(0));
for s = 1:num_stims
    stimTable = readtable(response_files{s},'ReadRowNames',true);
    stimTable.Properties.VariableNames = strcat(stimTable.Properties.VariableNames,['_stim' num2str(s)]);
   
    if sum(cellfun(@strcmp, stimTable.Properties.VariableNames, genoTable.Properties.VariableNames))~=0
        error(['The individuals in the genotype file do not match the individuals in the file: ' response_files{s}]);
    end
    if s==1
        respTable=stimTable;
    else
        respTable = join(respTable,stimTable,'Keys','RowNames');
    end
end
clear s stimTable var_names


% // (4) Remove genes that are not embedded in the network:
embedded_genes = ismember(respTable.Properties.RowNames,my_net.genes);
respTable = respTable(embedded_genes,:);



% // (5) Calculate a score for each SNP and each branch:
scoreTable = array2table(zeros(num_snps,num_branches));
var_names = cell(num_branches,1);
for br = 1:num_branches  
    var_names{br} = ['br' num2str(br)];
end
scoreTable.Properties.VariableNames = var_names;
scoreTable.Properties.RowNames = genoTable.Properties.RowNames;

  
for snp = 1:num_snps
    if mod(snp,50)==1
        disp(['snp ' num2str(snp)]);
    end

    for br = 1:num_branches
        scoreTable{snp,br} = gevinScoreCalculation(my_net, br, respTable, genoTable, snp, zygo);
    end
end
clear snp br


writetable(scoreTable,output_file,'WriteRowNames',true);
disp('Finished');

toc

end

