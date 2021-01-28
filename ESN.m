function [Y, Wout] = ESN(label_train, norm_train_set, norm_test_set, dimention, num_gesture, a, reg)
%Based on the work from Mantas Lukoševičius
%https://mantas.info/code/simple_esn/
%https://mantas.info/wp/wp-content/uploads/simple_esn/minimalESN.m



initLen = 10; %initalisation length of ESN
trainLen = length(label_train)-initLen; %training length of feature set
testLen = length(norm_test_set); %testing length of feature set

%%
inSize = dimention; outSize = num_gesture; %input is dimention of feature out is gesture number

resSize = 1000; %reservoir size nx

rand( 'seed', 42 ); %seeds random numbers, Random numbers same every run.
%^important for consistancy in ESN results
%This can be removed^
Win = (rand(resSize,1+inSize)-0.5) .* 1; %input weight matrix of random numbers
% dense W:
W = rand(resSize,resSize)-0.5; %weighted interconnection generated randomly

% normalizing and setting spectral radius
opt.disp = 0;
rhoW = abs(eigs(W,1,'LM',opt));
% disp 'done.'
W = W .* (1.25 / rhoW);  %can change echo state property here
% allocated memory for the design (collected states) matrix
X = zeros(1+inSize+resSize,trainLen-initLen); %Set X for testLen, high dimentional space
% set the corresponding target matrix directly
Yt = label_train(initLen+1:trainLen); %label of testing set

% run the reservoir with the data and collect X(n)
x = zeros(resSize,1);
for t = 1:trainLen
	u = norm_train_set(:,t);
    
	x = (1-a)*x + a*tanh( Win*[1;u] + W*x ); %activation function tanh used
    %check for desired input range
    
	if t > initLen 
		X(:,t-initLen) = [1;u;x]; 
	end
end

%Yt label is remapped
Yt_remap = zeros(num_gesture,trainLen-initLen);
for j = 1:41
Yt_remap(j,find(Yt==(j-1))) =1;
end



%%

% train the output by ridge regression

% using Matlab mldivide solver:

Wout = ((X*X' + reg*eye(1+inSize+resSize)) \ (X*Yt_remap'))'; %regularization

%output matrix is premade
Y = zeros(outSize, testLen-initLen);
u = norm_test_set(:,1); 

%generates output Y(n)
for t = 1:testLen 
	x = (1-a)*x + a*tanh( Win*[1;u] + W*x );
	y = Wout*[1;u;x];
	Y(:,t) = y; 

	u = norm_test_set(:,t); 
    
end
end
