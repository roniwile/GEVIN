function [ descendants ] = findDescendants( my_net, node_num )
%FINDDESCENDENTS finds all nodes downstram to node_num
% % % % % % % % % % % % % % % % % % % % % % % % % % % % 

dag = my_net.dag;
descendants = [];
curr = node_num;

while ~isempty(curr)
    curr_node = curr(1,1);
    for i = 1:length(dag)
        if dag(curr_node,i)==1
            curr = [curr i];
        end
    end
    curr = curr(1,2:end);
    if curr_node ~= node_num
        descendants = [descendants curr_node];    
    end
end

descendants = unique(descendants);

end

