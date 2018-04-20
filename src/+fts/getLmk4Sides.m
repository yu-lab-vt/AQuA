function lmkMsk4 = getLmk4Sides(H0,W0)

lmkMsk4 = cell(4,1);
for ii=1:4
    tmp = zeros(H0,W0);
    % south, north, west, east
    switch ii
        case 1
            tmp(end,:) = 1;
        case 2
            tmp(1,:) = 1;
        case 3
            tmp(:,1) = 1;
        case 4
            tmp(:,end) = 1;
    end
    lmkMsk4{ii} = tmp;
end

end