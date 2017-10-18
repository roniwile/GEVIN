function [ ancestors ] = findAncestors( my_net, node_num )
%FINDANCESTORS finds all nodes upstream to node_num
% % % % % % % % % % % % % % % % % % % % % % % % % % % % 

dag = my_net.dag;
ancestors = [];
curr = node_num;

while ~isempty(curr)
    curr_node = curr(1,1);
    for i = 1:length(dag)
        if dag(i,curr_node)==1
            curr = [curr i];
        end
    end
    curr = curr(1,2:end);
    if curr_node ~= node_num
        ancestors = [ancestors curr_node];    
    end
end

ancestors = unique(ancestors);

end

