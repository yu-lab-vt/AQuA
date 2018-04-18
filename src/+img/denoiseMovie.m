function vidDn = denoiseMovie( vidDc )
%denoiseMovie use VMB4D to denoise the movie
% To speed up, the movie is cut to many time segments and each segment is de-noised separately
% Theoratically this may reduce the performance, but for most cases there is no real difference

vidDn = zeros(size(vidDc));
tGap = 30;
nSeg = floor(size(vidDc,3)/tGap);

res = {};
parfor kk=1:nSeg
    disp(kk)
    if kk<nSeg
        rg = (kk-1)*tGap+1:kk*tGap;
    else
        rg = (kk-1)*tGap+1:size(vidDc,3);
    end
    vid0 = vidDc(:,:,rg);
    res{kk} = vbm4d(vid0);
end
for kk=1:nSeg
    if kk<nSeg
        rg = (kk-1)*tGap+1:kk*tGap;
    else
        rg = (kk-1)*tGap+1:size(vidDc,3);
    end   
    vid0Dn = res{kk};
    vidDn(:,:,rg) = vid0Dn;
end


end

