function result=isSuperGraph(sub,super)
if isempty(sub)||isempty(super)
    result=0;
else    
    [count,t]= graphmatch (sub,super, 1, 0);
    if count>0
       result=1;
    else
       result=0;
    end
end