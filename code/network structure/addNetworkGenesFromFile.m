function [ my_net ] = addNetworkGenesFromFile( my_net , gene_embedding_file )

geneTable = readtable(gene_embedding_file);

if ~isempty(setdiff(my_net.tfs,geneTable.Properties.VariableNames(2:end)))
    error('ERROR: the TFs in the file do not match the TFs of the network');  
end

% // Add genes to the network:
i = length(my_net.nodes_name);
my_net.genes = geneTable.gene';
my_net.nodes_name = [my_net.nodes_name my_net.genes];

num_genes = length(my_net.genes);
my_net.dag = [my_net.dag; zeros(num_genes,size(my_net.dag,2))];
my_net.dag = [my_net.dag zeros(size(my_net.dag,1),num_genes)];


for tf = my_net.tfs
    idx_net = strcmp(my_net.nodes_name,tf);
    idx_tbl = strcmp(geneTable.Properties.VariableNames,tf);
    tf_genes = find(geneTable{:,idx_tbl}==1);
    my_net.dag(idx_net,tf_genes+i) = 1;
end

end

