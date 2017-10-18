classdef Branch 
%  BRANCH    start_node -> end_node, represented by a proxy node

    properties    % all nodes are STRING NAMES
        StartNode;
        EndNode;
        Proxy;
    end
    
    methods
        
      % constructor:
      function my_branch = Branch(start_node,end_node,proxy)
         my_branch.StartNode = start_node;
         my_branch.EndNode = end_node;
         my_branch.Proxy = proxy;
      end
      
      function [branch_name] = branchName(my_branch)
          branch_name = ['node' num2str(my_branch.StartNode) '_to_node' num2str(my_branch.EndNode) '_(proxy_' num2str(my_branch.Proxy) ')'];
      end  % branchName(curr_branch)
      
      function [branch_name] = toString(my_branch)
          branch_name = strcat(my_branch.StartNode,{' to '},my_branch.EndNode);
      end  % branchName(curr_branch)
      
      
      
      % set funcs:
      function my_branch = setStartNode(my_branch,start_node)
            my_branch.StartNode = start_node;
      end
      
      function my_branch = setEndNode(my_branch,end_node)
            my_branch.EndNode = end_node;
      end
           
      function my_branch = setProxy(my_branch,proxy)
            my_branch.Proxy = proxy;
      end
      
      function my_branch = addProxy(my_branch, proxy)
            my_branch = setProxy(my_branch,[my_branch.Proxy {proxy}]);
      end
      
      
      % get funcs:
      function start_node = getStartNode(my_branch)
            start_node = my_branch.StartNode;
      end
      
      function end_node = getEndNode(my_branch)
            end_node = my_branch.EndNode;
      end
      
      function proxy = getProxy(my_branch)
            proxy = my_branch.Proxy;
      end
     
      
      function start_node = getStartNodeIdx(my_branch, my_net)
          start_node =  find(strcmp(my_net.nodes_name ,getStartNode(my_branch)));
      end
      
      function end_node = getEndNodeIdx(my_branch, my_net)
          end_node =  find(strcmp(my_net.nodes_name ,getEndNode(my_branch)));
      end
      
       function proxy = getProxyIdx(my_branch, my_net)
          proxy =  find(strcmp(my_net.nodes_name ,getProxy(my_branch)));
      end
  
            
      % branch list funcs:    
      function bool = checkIfInBranchList(my_branch, branches_list)
          bool = false;
          if ~isempty(branches_list)
              my_start = getStartNode(my_branch);
              my_end = getEndNode(my_branch);
              for i=1:length(branches_list)
                 curr_branch = branches_list(i);
                 curr_start = getStartNode(curr_branch);
                 curr_end = getEndNode(curr_branch);
                 if ((my_start==curr_start)&&(my_end==curr_end))
                     bool = true;
                     return;
                 end
              end
          end
      end
      
      function [branches_list] = addToBranchList(my_branch, branches_list)
           if isempty(branches_list)
               branches_list(1) = my_branch;
           else
              bool=true;
              my_start = getStartNode(my_branch);
              my_end = getEndNode(my_branch);
              
              for i=1:length(branches_list)
                 curr_branch = branches_list(i);
                 curr_start = getStartNode(curr_branch);
                 curr_end = getEndNode(curr_branch);
                 
                 if (strcmp(my_start,curr_start)&& strcmp(my_end,curr_end))    % this branch already exists so add the proxy
                     curr_branch = addProxy(curr_branch, getProxy(my_branch));
                     branches_list(i) = curr_branch;
                     bool=false;
                 end
              end
              
              if bool==true
                branches_list(length(branches_list)+1) = my_branch;
              end   
           end
      end
      
      function [branches_list] = removeFromBranchList(my_branch, branches_list)
           if ~isempty(branches_list)
              my_start = getStartNode(my_branch);
              my_end = getEndNode(my_branch);
              
              for i=1:length(branches_list)
                 curr_branch = branches_list(i);
                 curr_start = getStartNode(curr_branch);
                 curr_end = getEndNode(curr_branch);
                 
                 if ((my_start==curr_start)&&(my_end==curr_end))    
                     branches_list(i) = [];
                 end
              end  
           end
      end
      
      function [sorted_branches_list] = sortBranchList(branches_list,my_net)
         start_nodes_list = zeros(1,length(branches_list));
         for i=1:length(branches_list)
            start_nodes_list(i) = getStartNodeIdx(branches_list(i),my_net);
         end
         [~, idx] = sort(start_nodes_list);
         sorted_branches_list = branches_list(idx);
      end
      
      function [sorted_branches_list] = sortBranchListByProxy(branches_list)
         proxy_nodes_list = cell(1,length(branches_list));
         for i=1:length(branches_list)
            proxy_nodes_list{i} = getProxyIdx(branches_list(i),my_net);
         end
         [~, idx] = sort(proxy_nodes_list);
         sorted_branches_list = branches_list(idx);
      end
      
      
      % mergable branches funcs:     
      function [bool] = checkMergableBranches(branch1, branch2)
         bool = ((getStartNode(branch1)==getStartNode(branch2))&&(getEndNode(branch1)==getEndNode(branch2)));       
      end
            
      function [merged_branch] = mergeBranches(branch1, branch2)
          new_start = getStartNode(branch1);
          new_end = getEndNode(branch1);
          new_proxy = [getProxy(branch1) getProxy(branch2)];

          merged_branch = Branch(new_start,new_end,new_proxy);
      end
      
      
      % concatinatable branches funcs:
      function [bool] = checkConcatination(branch1, branch2)
          inter = intersect(getProxy(branch1),getProxy(branch2),'stable');   
          bool = ~isempty(inter) && ~strcmp(inter,'mock');
      end
      
      function [concat_branch] = concatenateBranches(branch1, branch2, my_net)
          if  getStartNodeIdx(branch1,my_net) <  getStartNodeIdx(branch2,my_net)
              new_start = getStartNode(branch1);
          else
              new_start = getStartNode(branch2);
          end
          
          if  getEndNodeIdx(branch1,my_net) >  getEndNodeIdx(branch2,my_net)
              new_end = getEndNode(branch1);
          else                                          % branch2 -> branch1
              new_end = getEndNode(branch2);
          end
          
          new_proxy = unique([getProxy(branch1) getProxy(branch2)],'stable');
          concat_branch = Branch(new_start,new_end,new_proxy);
      end
      
      
      
      % check if node is in branch funcs:
      
      function [bool, branch]= checkIfProxy(node, branches_list)
          branch = [];
          bool = false;
          for branch=branches_list
              curr_proxy = getProxy(branch);
              if curr_proxy==node
                  bool = true;
                  return;
              end              
          end
      end
      
      function [bool, branch]= checkIfStartNode(node, branches_list)
          branch = [];
          bool = false;
          for branch=branches_list
              curr_start = getStartNode(branch);
              if curr_start==node
                  bool = true;
                  return;
              end              
          end
      end
      
      function [bool, branch]= checkIfEndNode(node, branches_list)
          branch = [];
          bool = false;
          for branch=branches_list
              curr_end = getEndNode(branch);
              if curr_end==node
                  bool = true;
                  return;
              end              
          end
      end
      
      function [bool, branch]= checkIfBranchContains(node, branches_list)
          branch = [];
          bool = false;
          for branch=branches_list
              branch_nodes = [getProxy(branch) getStartNode(branch) getEndNode(branch)];
              if ismember(node,branch_nodes)
                  bool = true;
                  return;
              end              
          end
      end
      
      
    end
    
end

