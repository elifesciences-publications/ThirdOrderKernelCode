function primeList = GenerateNPrimes( n )
    % primeList = GenerateNPrimes( n )
    %
    % Generates n primes by repeatedly calling primes(k) until
    % length(primes(k))>n. The first k it tries is n*ln(n)*1.5 and subsequent
    % steps multiply k by 2.

    k = n*log(n)*1.5;
    primeList = [];

    while length(primeList) < n
        primeList = primes(k);
        k = k*2;
    end

    primeList = primeList(1:n);
end