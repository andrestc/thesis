function [ pdf ] = KDE(X, P, ws )
% kernel density estimation for multidimensional data
% X  - observations to compute density
% P - observations given as support
% ws - variance/co-variance of the Gaussian

    pdf = zeros(size(X,1),1);

    if size(P,1) == 0 || size(X,1) == 0 || ws(1) == 0
        return
    end

    for i = 1:size(X,1)
        pdf(i) = 1/size(P,1) * sum(mvnpdf(P(:,:), X(i,:), ws));
    end

end
