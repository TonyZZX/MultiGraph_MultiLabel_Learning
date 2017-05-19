function y=min_max_norm(min_value,max_value,x)
%normalize each column of the input matrix x using min max normalization
%min_value is the lower bound after normalization and max_value is the upper bound after normalization

if(max_value<=min_value)
  error('max value can"t be lower than min value');
end

size_x=size(x);
y=zeros(size_x);
for col=1:size_x(2)
   max_col=max(x(:,col));
   min_col=min(x(:,col));
   for line=1:size_x(1)
      if(max_col==min_col)
         y(line,col)=(max_value+min_value)/2;
      else
         y(line,col)=((x(line,col)-min_col)/(max_col-min_col))*(max_value-min_value)+min_value;
      end
   end
end
