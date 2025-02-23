function [root, iter] = Bisezione(func, a, b, tol, maxIter)
    % Metodo di bisezione per trovare una radice di una funzione continua
    %
    % INPUT:
    % func     : funzione anonima (es. @(x) x^2 - 4)
    % a, b     : estremi dell'intervallo iniziale [a, b]
    % tol      : tolleranza desiderata per la radice
    % maxIter  : numero massimo di iterazioni
    %
    % OUTPUT:
    % root     : approssimazione della radice
    % iter     : numero di iterazioni eseguite
    
    % Non facciamo il check della condizione sufficiente e non necessaria 
    % perché sappiamo già che c'è un'intersezione con l'asse zero in 
    % quell'intervallo. Inoltre essendo una condizione sufficiente ma non
    % necessaria a volte potrebbe dare errore nonostante ci sia
    % l'intersezione.

    % % Verifica iniziale: f(a) e f(b) devono avere segno opposto
    % if func(a) * func(b) >= 0
    %     error('La funzione non cambia segno nell''intervallo [a, b].');
    % end
    
    % Inizializza variabili
    iter = 0;
    root = (a + b) / 2; % Punto medio iniziale
    
    while (b - a) / 2 > tol && iter < maxIter
        iter = iter + 1; % Conta l'iterazione
        root = (a + b) / 2; % Calcola il punto medio
        
        % Valuta la funzione nel punto medio
        f_root = func(root);
        
        % Aggiorna l'intervallo in base al segno di f(root)
        if f_root == 0
            % Trovata la radice esatta
            break;
        elseif func(a) * f_root < 0
            b = root; % La radice è nell'intervallo [a, root]
        else
            a = root; % La radice è nell'intervallo [root, b]
        end
        (b - a) / 2;
    end
    
    % Avviso se il numero massimo di iterazioni è raggiunto
    if iter == maxIter
        warning('Numero massimo di iterazioni raggiunto. La soluzione potrebbe non essere precisa.');
    end
end
