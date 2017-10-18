function [ my_net ] = createBranchList( my_net )
%CREATEBRANCHLIST takes as input a dag from my_net and builds the appropriate pathways
%(legal_branches_list)
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


my_dag = my_net.dag;
my_nodes = my_net.nodes_name;



% // (1) Create the initial list which contain all branches:
[from_nodes,to_nodes] = find(my_dag);  
from_out_degrees = sum(my_net.dag,2)'; 
to_in_degrees = sum(my_net.dag);

num_branches = sum(sum(my_dag));
branches_list = Branch.empty(0,0);

my_new_nodes = my_nodes;
i = 1;
for br=1:num_branches
   bool=true;
   br_from = from_nodes(br);
   br_to = to_nodes(br);
   
   from_out_deg = from_out_degrees(br_from);
   to_in_deg = to_in_degrees(br_to);
   
   if (from_out_deg==1)   % if predecessor out_degree is 1 it can be a proxy for the branch     
       my_branch =  Branch(my_nodes{br_from},my_nodes{br_to},my_nodes{br_from});
       [branches_list] = addToBranchList(my_branch, branches_list);
       bool=false;
   end
   
   if (to_in_deg==1)   % if successor in_degree is 1 it can be a proxy for the branch
       my_branch =  Branch(my_nodes{br_from},my_nodes{br_to},my_nodes{br_to});
       [branches_list] = addToBranchList(my_branch, branches_list);
       bool=false;
   end
   
   if bool==true     % otherwise add a mock node as proxy and build appropriate nodes
       mock_node=['mock' num2str(i)];
       
       my_branch =  Branch(my_nodes{br_from},mock_node,mock_node);
       [branches_list] = addToBranchList(my_branch, branches_list);
       my_branch =  Branch(mock_node,my_nodes{br_to},mock_node);
       [branches_list] = addToBranchList(my_branch, branches_list);
       
       my_new_nodes = [my_new_nodes(1:br_from) mock_node my_new_nodes((br_from+1):end)];
       i=i+1;
       
   end
end
clear  num_branches bool br my_branch br_from br_to from_nodes to_nodes from_out_deg to_in_deg 
clear from_out_degrees to_in_degrees mock_idx my_dag my_new_dag i mock_node num_initial_branches my_nodes


% // (2) Update DAG after mock-nodes addition:
new_dag = zeros(length(my_new_nodes));
for br=1:length(branches_list);
    br_from_name = getStartNode(branches_list(br));
    br_to_name = getEndNode(branches_list(br));
    
    br_from = strcmp(my_new_nodes,br_from_name);
    br_to = strcmp(my_new_nodes,br_to_name);
    
    new_dag(br_from,br_to)=1;
end
my_net.dag = new_dag;
my_net.nodes_name = my_new_nodes;
clear new_dag my_new_nodes br br_from br_from br_to br_to_name



% // (3) Concatenate branches with same proxy: (=creating pathways)
bool = true;
num_legal_branches = length(branches_list);
while(bool)
    bool = false;  
    branches_list = sortBranchList(branches_list, my_net);
    
    for i=1:(num_legal_branches-1)
        branch1 = branches_list(i);  
        
        for j=i+1:(num_legal_branches)            
            branch2 = branches_list(j); 
            
            if checkConcatination(branch1, branch2)  
                if ismember(getStartNode(branch2), my_net.stims) % don't concatenate a branch starting from stim
                    continue;
                end
                
                bool = true;
                concat_branch = concatenateBranches(branch1, branch2, my_net);
                branches_list([i j]) = [];
                num_legal_branches = num_legal_branches-2+1;
                branches_list(num_legal_branches)=concat_branch;
                break;
            end

        end
        if bool
            break;
        end
    end
end
clear bool i j branch1 branch2 concat_branch num_legal_branches;


% //(4) Choose one LEGAL proxy for a branch:  (not a stimulaion; a proxy must be a component)
proxy_list = cell(0);
for i=1:length(branches_list)    
    bool = true;
    curr_proxy_arr = getProxy(branches_list(i));
    if isa (curr_proxy_arr,'char')
        curr_proxy_arr = {curr_proxy_arr};
    end
    for j=1:length(curr_proxy_arr)
        curr_proxy = curr_proxy_arr(j);    
        if ~(ismember(curr_proxy,my_net.stims))&&~(ismember(curr_proxy,proxy_list))
            branches_list(i) = setProxy(branches_list(i),curr_proxy);
            proxy_list = [proxy_list curr_proxy];
            bool = false;
            break;
        end
    end
    
    if(bool)  % if the only proxy is stimulation - replace with a new mock node
        error('ERROR: only possible proxy is a stimulation');         
    end  
end
[branches_list] = sortBranchList(branches_list, my_net);
clear i j curr_proxy_arr curr_proxy try_proxy bool my_name idx_to_remove mock_node start_node end_node;


my_net.branches_list = branches_list;


end

