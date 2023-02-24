% FUNCTION NAME:
%   random_generator
%
% DESCRIPTION:
%   generating matrix with random numbers between a lower and upper band, evenly distributed randomly
%   
%
% INPUT:
%   a = [1x1] Lower bound of the random range
%   b = [1x1] Upper bound of the random range
%   dim = [MxN] Size of the random matrix
%
% OUTPUT:
%   random_matrix = [MxN] Random generated matrix
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   23/2/2023 - Sina Es haghi
%       * Initial implementation
%
function random_matrix = random_generator (a,b,dim)

random_matrix = a + (b-a).*rand(dim(1),dim(2));

end