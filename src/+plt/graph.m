function graph( pEdge,dEdge,st01,nodePos,nodeLbl,edgeWt )
    %DRAWGRAPH Draws primal and dual graphs
    
    % original edges
    f00 = figure;
    axNow = axes(f00);
    scatter(axNow,st01(1:2:end),st01(2:2:end),1,[1 0.5 0]);hold on
    for kk=1:size(pEdge,1)
        x = [pEdge(kk,1),pEdge(kk,3)];
        y = [pEdge(kk,2),pEdge(kk,4)];
        drawArrow(axNow,x,y,[0.5 0.5 0.5]);
        x = [dEdge(kk,1),dEdge(kk,3)];
        y = [dEdge(kk,2),dEdge(kk,4)];
        drawArrow(axNow,x,y,[0.5,0.5,1]);
        %text(mean(x),mean(y),num2str(sWeight(kk),'%f'));
    end
    xlabel('Ref');ylabel('Tst');
    
    col = {'g','r'};
    for ii=0:1
        x = nodePos(nodeLbl==ii,1);
        y = nodePos(nodeLbl==ii,2);
        scatter(axNow,x,y,10,col{ii+1});
    end
    
    for ii=1:size(nodePos,1)
        text(nodePos(ii,1),nodePos(ii,2),num2str(ii));        
    end
    
    for ii=1:size(edgeWt,1)
        n0 = edgeWt(ii,1);
        n1 = edgeWt(ii,2);
        x = (nodePos(n0,1)+nodePos(n1,1))/2;
        y = (nodePos(n0,2)+nodePos(n1,2))/2;
        text(x,y,num2str(edgeWt(ii,3)),'Color','m');
    end    
end


function drawArrow(axNow,x,y,colIn)
    
    pos = [x(1) y(1) x(2)-x(1) y(2)-y(1)];
    hOut = annotation('arrow');
    hOut.Color = colIn;
    
    set(hOut,'parent',axNow);
    set(hOut,'position',pos);
    
end



