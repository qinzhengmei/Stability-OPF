function [h1,h2,h3,h4,h5,h6] = hFunction(delta,e,theta,V,...
    pg,qg,xq_vec,xprime_vec)
%HFUNCTION computes h(x,a,u); i.e., algebraic equations in DAE.  
%  [h1,h2,h3,h4,h5,h6] = hFunction(delta,e,theta,V,...
%     pg,qg,xq_vec,xprime_vec) computes the algebraic equations of 
% function h based on equations (2a)--(3b)
%
% Description of outputs:
% 1. h1: size(G,1) right-hand side of equation (2a)
% 2. h2: size(G,1) right-hand side of equation (2b)
% 3. h3: size(G,1) right-hand side of equation (2c)
% 4. h4: size(G,1) right-hand side of equation (2d)
% 5. h5: size(L,1) right-hand side of equation (3a)
% 6. h6: size(L,1) right-hand side of equation (3b)
%
% Description of inputs:
% 1. delta: size(G,1) instantaneous internal angle of generator in radians
% 2. e: size(G,1) instantaneous electromotive force
% 3. theta: size(N,1) instantaneous terminal angle of nodes in radians
% 4. V: size(N,1) instantaneous terminal voltage magnitude of nodes in
% pu volts
% 5. pg: size(G,1) instantaneous real power generated by the generator
% 6. qg: size(G,1) instantaneous reactive power generated by the generator
% 7. xq_vec: size(G,1) vector of quadrature axis synchronous reactance (pu)
% 8. xprime_vec: size(G,1) vector of direct axis transient reactance (pu)
% 
% See also hFunctionVectorized
%
% Required:
% 1. Fix equation numbers. 

% h1--h4 size(G,1)
% h5,h6 size(L,1)

global  G L  gen_set load_set Gmat Bmat...
    

h3=zeros(G,1);
h4=zeros(G,1);
h5=zeros(L,1);
h6=zeros(L,1);


thetag=theta(gen_set);
Vg=V(gen_set);

h1=-pg+ (1./xprime_vec).*(e.*Vg.*sin(delta-thetag))+...
    ((xprime_vec-xq_vec)./(2.*xq_vec.*xprime_vec)).*...
    (Vg.^2).*sin(2*(delta-thetag));

h2=-qg+(1./xprime_vec).*(e.*Vg.*cos(delta-thetag))-...
    ((xprime_vec+xq_vec)./(2.*xq_vec.*xprime_vec)).*(Vg.^2)...
    + ((xprime_vec-xq_vec)./(2.*xq_vec.*xprime_vec)).*(Vg.^2).*cos(2*(delta-thetag));


% these can be vectorized (future)
for ii=1:length(gen_set)
idx=gen_set(ii); % network index
h3(ii)=-pg(ii) +...
    V(idx).*(Gmat(idx,:)*(V.*cos(theta(idx)-theta))+Bmat(idx,:)*(V.*sin(theta(idx)-theta)));
h4(ii) = -qg(ii) +...
    V(idx).*(-Bmat(idx,:)*(V.*cos(theta(idx)-theta))+Gmat(idx,:)*(V.*sin(theta(idx)-theta)));

end


% these can be vectorized:
for ii=1:length(load_set)
idx=load_set(ii); % network index
h5(ii)= ...
      V(idx).*(Gmat(idx,:)*(V.*cos(theta(idx)-theta))+Bmat(idx,:)*(V.*sin(theta(idx)-theta)));
h6(ii) =...
    V(idx).*(-Bmat(idx,:)*(V.*cos(theta(idx)-theta))+Gmat(idx,:)*(V.*sin(theta(idx)-theta)));
end


