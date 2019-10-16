function c0 = curvePolyDeTrend(c0,s0,correctTrend)

if ~exist('correctTrend','var')
    correctTrend = 0;
end

c0 = reshape(double(c0),[],1);
% cIn = c0;

% bgFluo = 0;
% thrxx = 0.1;

% curve fitting to remove trend
% exclude event time points
if correctTrend>0
    x = (1:numel(c0))';
    y = c0;
    
%     while 1
%         tExc = unique([t0:t1,find(r0>thrxx),find(ar0>thrxx)]);
%         if numel(tExc)<numel(y)*0.8
%             break
%         end
%         thrxx = thrxx+0.1;
%     end
%     try
%         model0 = ['poly',num2str(opts.correctTrend)];
%         f0 = fit(x,y,model0,'Exclude',sort(tExc));
%     catch
%         keyboard
%     end
    
    try
        model0 = ['poly',num2str(correctTrend)];
        f0 = fit(x,y,model0,'Exclude',find(s0));
        yFit = f0(x);
        c0 = y - yFit;
        c0 = c0 - min(c0) + min(y);
    catch
        warning('Curve trend removal error');
        disp(c0);
        disp(s0);
        save(['debug_deTrend_',num2str(randi(1e8)),'.mat'],'c0','s0');
    end
end

end