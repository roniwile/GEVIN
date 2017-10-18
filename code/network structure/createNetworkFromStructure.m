function [ my_net ] = createNetworkFromStructure( my_net ,branchTable )
%CREATENETWORKFROMSTRUCTURE Summary of this function goes here
%   Detailed explanation goes here


N = length(my_net.nodes_name);
my_net.dag = zeros(N,N);

% // Create DAG according to list of branches:
for i=1:size(branchTable,1)
    from_idx = strcmp(my_net.nodes_name,branchTable.from(i));
    to_idx = strcmp(my_net.nodes_name,branchTable.to(i));
    my_net.dag(from_idx,to_idx) = 1;
end
clear i from_idx to_idx;

% // Check postorder consistency:
for row = 1:N  
    for col = 1:row
        if (my_net.dag(row,col) == 1)
          error('ERROR: nodes do not follow the postorder rule');  
        end
    end
end
clear row col;


% // Check that all branches appear in DAG:
if sum(sum(my_net.dag))~=size(branchTable,1)
    error('ERROR: problem with nodes name');
end



% // Create legal branch list according to DAG:
my_net = createBranchList(my_net); 


for br = 1:length(my_net.branches_list)
    disp(['branch_' num2str(br) ': ']);
    disp(toString(my_net.branches_list(br)));
end


end

