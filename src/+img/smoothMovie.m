function [ vidVST,varEstSmo ] = smoothMovie( vidVST,varEst,useSmo,sigmaXY,sigmaZ )
%SMOOTHDATA Smooth movie temporally and/or spatially
% Noise is updated
% Reduced memory usage

if isempty(varEst)
    varEst = 0.01;
end

[H,W,T] = size(vidVST);

% vidVST = vidVST;
varEstSmo = varEst;

vidRef = zeros(128,128,30); 
vidRef = vidRef + randn(size(vidRef))*sqrt(varEst);
vidRefSmo = vidRef;

% temporal smoothing
if useSmo==1
    fLen = 3;
    locIn = -fLen:fLen;
    ker0 = normpdf(locIn,0,sigmaZ); ker0 = ker0/sum(ker0);
    
    % padding for smoothing with less artifacts
    vt1 = vidVST(:,:,1);
    vt1Pad = repmat(vt1,1,1,10);
    vtE = vidVST(:,:,end);
    vtEPad = repmat(vtE,1,1,10);
    vidx = cat(3,vt1Pad,vidVST,vtEPad);    
    
    vidx = reshape(vidx,[],size(vidx,3));
    vidx = conv2(vidx,ker0);
    vidx = vidx(:,fLen+1:end-fLen);
    vidx = reshape(vidx,H,W,size(vidx,2));
    
    vidVST = vidx(:,:,11:(T+10));
    
%     v1 = vidSmo(:,:,1); v2 = vidSmo(:,:,2);
%     ve = vidSmo(:,:,end); ve2 = vidSmo(:,:,end-1);
%     v1 = v1 + median(v2(:)) - median(v1(:));
%     ve = ve + median(ve2(:)) - median(ve(:));
%     vidSmo(:,:,1) = v1; vidSmo(:,:,end) = ve;

%     vidRefSmo = reshape(vidRef,[],T);
%     vidRefSmo = conv2(vidRefSmo,ker0);
%     vidRefSmo = vidRefSmo(:,fLen+1:end-fLen);
%     vidRefSmo = reshape(vidRefSmo,H,W,T);
%     vidRefSmo = vidRefSmo(:,:,3:end-2);
%     varEstSmo = var(vidRefSmo(:));
end

% spatial smoothing
if useSmo==2
    if sigmaXY>0
        for tt=1:T
            vid0 = vidVST(:,:,tt);
            vid0 = imgaussfilt(vid0,sigmaXY);
            vidVST(:,:,tt) = vid0;
%             if tt<=30
%                 vid0 = vidRefSmo(:,:,tt);
%                 vid0 = imgaussfilt(vid0,sigmaXY);
%                 vidRefSmo(:,:,tt) = vid0;
%             end
        end
%         varEstSmo = var(vidRefSmo(:));
    end
end

% 3D smoothing
if useSmo==3
    ft0 = getGaussianKernel3D(sigmaXY,sigmaZ);
    
    % padding for smoothing with less artifacts
    vt1 = vidVST(:,:,1);
    vt1Pad = repmat(vt1,1,1,10);
    vtE = vidVST(:,:,end);
    vtEPad = repmat(vtE,1,1,10);
    vidVST = cat(3,vt1Pad,vidVST,vtEPad);    
    
    vidVST = imfilter(vidVST,ft0,'symmetric');
    vidVST = vidVST(:,:,11:(T+10));
    
%     vidRefSmo = imfilter(vidRef,ft0);
%     vidRefSmo = vidRefSmo(:,:,3:end-2);
%     varEstSmo = var(vidRefSmo(:));
end

end

function gaussKernel = getGaussianKernel3D(sigmaXY,sigmaZ)
X = 5; Y = 5; Z = 5;
Xc = (X+1)/2; Yc = (Y+1)/2; Zc = (Z+1)/2;
twoSigmaXY2 = 2*sigmaXY^2;
twoSigmaZ2 = 2*sigmaZ^2;
gaussKernel = zeros(X,Y,Z);
for x = 1:X
    for y=1:Y
        for z=1:Z
            radiusSquared = (x-Xc)^2/twoSigmaXY2 + (y-Yc)^2/twoSigmaXY2 + (z-Zc)^2/twoSigmaZ2;
            gaussKernel(x, y, z) = exp(-radiusSquared);
        end
    end
end
gaussKernel = gaussKernel/sum(gaussKernel(:));
end








