function [ upstream_stims, downstream_genes ] = findBranchActivationSignature( my_net, br )

proxy = getProxyIdx(my_net.branches_list(br), my_net);

% // Find upstream stimulations:
idx = findAncestors(my_net, proxy);
ancestors = my_net.nodes_name(idx);
upstream_stims = intersect(ancestors,my_net.stims);


% // Find downstream genes:
idx = findDescendants(my_net, proxy);
descendants = my_net.nodes_name(idx);
downstream_genes = intersect(descendants,my_net.genes);


if isempty(upstream_stims) || isempty(downstream_genes)
    error('Problem with branch activation signature');
end


end