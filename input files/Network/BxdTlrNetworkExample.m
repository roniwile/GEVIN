function [ ] = BxdTlrNetworkExample(net_name, gene_embedding_file)
%
% This script is an example file of how to create a new molecular network.
% 
% Please follow the instructions of how to define the network structure.
% The structure of the network used here can be found in the user guide.
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

if nargin==0
    net_name = 'BxdTlrNet';
    gene_embedding_file = 'bxd_tlr_genes_embedding.xlsx';
end

my_net.nodes_name = {'snp'};
my_net.snp = {'snp'};


% // (1) Add noode name for each molecular componenet in the network. 
%        Nodes should follow toplogical order (ancestors before descendants). 
% <<user_start>>
my_net.nodes_name = [my_net.nodes_name {'pam','lps','poly','tlr2','tlr4','tlr3','myd88','trif','nfkb','irf3'}];
% <<user_end>>
          

% // (2) Define molecular charachteristic of nodes - stimulations or transcription factors:
% <<user_start>>
my_net.stims = {'pam','lps','poly'};
my_net.tfs = {'nfkb','irf3'};
% <<user_end>>



% // (3) Define edges from one molecular comnponenet to another: 
branchTable = array2table(cell(0,2));
branchTable.Properties.VariableNames = {'from','to'};

% <<user_start>>
branchTable = [branchTable; {'pam','tlr2'}];
branchTable = [branchTable; {'lps','tlr4'}];
branchTable = [branchTable; {'poly','tlr3'}];
branchTable = [branchTable; {'tlr2','myd88'}];
branchTable = [branchTable; {'tlr4','myd88'}];
branchTable = [branchTable; {'tlr4','trif'}];
branchTable = [branchTable; {'tlr3','trif'}];
branchTable = [branchTable; {'myd88','nfkb'}];
branchTable = [branchTable; {'trif','irf3'}];
% <<user_end>>


% // (4) Create network strucute, including list of branches to test:
my_net = createNetworkFromStructure(my_net ,branchTable);


% // (5) Adding genes to the network according to file:
my_net = addNetworkGenesFromFile( my_net, gene_embedding_file);


save([net_name '.mat'], 'my_net');


