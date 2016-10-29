function RPS = phasespace(x,dim,tau)
    % phase space reconstruction using time delay embedding
    RPS=zeros(T,dim);
    for i=1:N-(dim-1)*tau
       RPS(i,:)=x(i+(0:dim-1)*tau)';
    end
end
