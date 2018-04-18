function d0 = getDistMat(ref,tst)
% Get Euclidean distance between two curves
% ref along height and tst along width

T = length(ref);
d0 = (repmat(reshape(ref,[],1),1,T) - repmat(reshape(tst,1,[]),T,1)).^2;

d0(isnan(d0)) = 0; % !!
d0 = double(d0);

end