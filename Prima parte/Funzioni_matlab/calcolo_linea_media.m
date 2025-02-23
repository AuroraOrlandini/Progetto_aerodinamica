function [linea_media]=calcolo_linea_media(Coord,graph)

%% Parametri
% Numero di punti
N=1000;

% Tolleranza linea media
toll=1e-4;

% Iterazioni massime linea media
it_max=10;

% Range filtro
space=round(N/5);

% Tolleranza bisezione
toll_b=1e-15;

% Iterazioni massime bisezione
it_max_b=1000;


%% Separo "dorso" e "ventre" (approssimati, separandoli con il punto a x min)
[~,I]=min(Coord.x);
% Ventre (coordinate dal BA al BU)
ventre.x=flip(Coord.x(1:I));
ventre.y=flip(Coord.y(1:I));
% Dorso (coordinate dal BA al BU)
dorso.x=Coord.x(I:end);
dorso.y=Coord.y(I:end);

%% Elimino, se presente, il punto doppio al bordo d'attacco
if ventre.x(1)==ventre.x(2)
    ventre.x(1)=[];
    ventre.y(1)=[];
end
if dorso.x(1)==dorso.x(2)
    dorso.x(1)=[];
    dorso.y(1)=[];
end


%% Funzioni interpolanti di dorso e ventre (makima)
pp_d=makima(dorso.x,dorso.y);
pp_v=makima(ventre.x,ventre.y);
spl_dorso=@(x) ppval(pp_d,x);
spl_ventre=@(x) ppval(pp_v,x);


%% Linea media (prima iterazione)
% Bordo d'uscita
BU_x=(dorso.x(end)+ventre.x(end))/2;

% Linea media
linea_media.x=linspace(min(Coord.x),BU_x,N)';
linea_media.y=((spl_dorso(linea_media.x)+spl_ventre(linea_media.x))./2);
linea_media_1=linea_media;

%% Verfico se il profilo è simmetrico
symm=0;
if length(dorso.x)==length(ventre.x) && norm(dorso.y+ventre.y) == 0
    symm=1;
    linea_media.y=zeros(length(linea_media.x));
end

if symm==0
    %% Metodo iterativo per il calcolo della linea media
    err=toll+1;
    it=0;
    while err>toll && it<it_max
        it=it+1;
        disp(it)
        %% Calcolo la tangente in ciascun punto della linea media tranne BU e BA
        dy_dx=zeros(length(linea_media.x),1);
        for r=2:length(linea_media.x)-1
            dy_dx(r)=(linea_media.y(r+1)-linea_media.y(r-1))/(linea_media.x(r+1)-linea_media.x(r-1));
        end
        %% Inizializzo la nuova linea media
        linea_media_new=linea_media;
    
        for i=2:length(linea_media.x)-1
            %% Retta normale alla linea media nel punto "i"
            m_i=(-1/dy_dx(i));
            q_i=linea_media.y(i)-m_i*linea_media.x(i);
            normale=@(x) m_i.*x + q_i;
    
            p.a(i,:)=-1;
            p.b(i,:)=-1;
    
            %% Ciclo per il ventre
            found=0;
            for j = 1:length(ventre.x)-1
                m_j=(ventre.y(j+1)-ventre.y(j))/(ventre.x(j+1)-ventre.x(j));
                q_j=ventre.y(j)-m_j*ventre.x(j);
                x_j=(q_j-q_i)/(m_i-m_j);
                % Verifico se il pannello "j" interseca la normale "i"
                if ventre.x(j+1) >= ventre.x(j) && x_j<=ventre.x(j+1) && x_j>=ventre.x(j)
                    found=1;
                    % Intervallo di riferimento per il metodo di bisezione
                    a = ventre.x(j);
                    b = ventre.x(j+1);
                    % Metodo di bisezione
                    f =@(x) spl_ventre(x) - normale(x);
                    [x] = Bisezione(f,a,b,toll_b,1e4);
    
                elseif ventre.x(j+1) <= ventre.x(j) && x_j>=ventre.x(j+1) && x_j<=ventre.x(j)
                    found=1;
                    % Intervallo di riferimento per il metodo di bisezione
                    a = ventre.x(j+1);
                    b = ventre.x(j);
                    % Metodo di bisezione
                    f =@(x) spl_ventre(x) - normale(x);
                    [x] = Bisezione(f,a,b,toll_b,1e4);
                end
            end
            % Assegno le coordinate delle intersezioni trovate
            if found==1 && p.a(i,1)==-1
                p.a(i,1)=x;
                p.a(i,2)=m_i*x+q_i;
            elseif found==1 && p.a(i,1)~=-1 && p.b(i,1)==-1
                p.b(i,1)=x;
                p.b(i,2)=m_i*x+q_i;
            end
            %% Ciclo per il dorso
            found=0;
            for j = 1:length(dorso.x)-1
                m_j=(dorso.y(j+1)-dorso.y(j))/(dorso.x(j+1)-dorso.x(j));
                q_j=dorso.y(j)-m_j*dorso.x(j);
                x_j=(q_j-q_i)/(m_i-m_j);
                if dorso.x(j+1) >= dorso.x(j) && x_j<=dorso.x(j+1) && x_j>=dorso.x(j)
                    found=1;
                    % Intervallo di riferimento per il metodo di bisezione
                    a = dorso.x(j);
                    b = dorso.x(j+1);
                    % Metodo di bisezione
                    f =@(x) spl_dorso(x) - normale(x);
                    [x] = Bisezione(f,a,b,toll_b,1e4);
    
                elseif dorso.x(j+1) <= dorso.x(j) && x_j>=dorso.x(j+1) && x_j<=dorso.x(j)
                    found=1;
                    % Intervallo di riferimento per il metodo di bisezione
                    a = dorso.x(j+1);
                    b = dorso.x(j);
                    % Metodo di bisezione
                    f =@(x) spl_dorso(x) - normale(x);
                    [x] = Bisezione(f,a,b,toll_b,1e4);
                end
            end
            % Assegno le coordinate delle intersezioni trovate
            if found==1 && p.a(i,1)==-1
                p.a(i,1)=x;
                p.a(i,2)=m_i*x+q_i;
            elseif found==1 && p.a(i,1)~=-1 && p.b(i,1)==-1
                p.b(i,1)=x;
                p.b(i,2)=m_i*x+q_i;
            end
    
    
            %% Aggiorno il punto "i" della nuova linea media
            linea_media_new.x(i)=(p.a(i,1)+p.b(i,1))/2;
            linea_media_new.y(i)=(p.a(i,2)+p.b(i,2))/2;
        end
    
        %% Filtro per eliminare le oscillazioni
        % Range del filtro in base al numero di punti richiesti
        linea_media_pref=linea_media_new;
        pesi=1-linspace(0,1,N).^7;

        for h=2:round(length(linea_media_new.x)-1)
            linea_media_new.y(h)=polyval(polyfit(linea_media_pref.x(max([h-space 2]):min([h+space length(linea_media_new.x)])),linea_media_pref.y(max([h-space 2]):min([h+space length(linea_media_new.x)])),3),linea_media_new.x(h))*pesi(h)+linea_media_pref.y(h)*(1-pesi(h));
        end

        % for h=round(length(linea_media_new.x)/2):length(linea_media_new.x)-1
        %     linea_media_new.y(h)=polyval(polyfit(linea_media_pref.x(h-6:min([h+space length(linea_media_new.x)])),linea_media_pref.y(h-6:min([h+space length(linea_media_new.x)])),5),linea_media_new.x(h));
        % end
        
        % for h=2:length(linea_media_new.x)-space-1
        %     linea_media_new.y(h:h+space)=(polyval(polyfit(linea_media_new.x(h:h+space),linea_media_new.y(h:h+space),4),linea_media_new.x(h:h+space))).*pesi(h:h+space)'+linea_media_pref.y(h:h+space).*(1-pesi(h:h+space))';
        % end
        
    
        %% Aggiungo il bordo d'attacco
        retta_BA=@(x) (linea_media_new.y(3)-linea_media_new.y(2))/(linea_media_new.x(3)-linea_media_new.x(2)).*(x-linea_media_new.x(2))+linea_media_new.y(2);
        
        % Intervallo di riferimento per il metodo di bisezione
        a=min(dorso.x);
        b=linea_media_new.x(2);
    
        % Ordinata del punto di ascissa minima
        [x_lim,I]=min(Coord.x);
        y_lim=Coord.y(I);
    
        % Metodo di bisezione
        if retta_BA(x_lim)>y_lim
            f =@(x) spl_dorso(x) - retta_BA(x);
        else
            f =@(x) spl_ventre(x) - retta_BA(x);
        end
    
        [linea_media_new.x(1)] = Bisezione(f,a,b,toll_b,it_max_b);
        linea_media_new.y(1)=retta_BA(linea_media_new.x(1));
    
    
        %% Calcolo l'errore e aggiorno la linea media e le coordinate di dorso e ventre
        err=max(abs(linea_media_new.y(1:end-1) - linea_media.y(1:end-1)));
        linea_media=linea_media_new;
        disp(err)
    end
end


%% Plot
% Determino i nuovi punti di dorso e ventre in base alla posizione del BA
[~,I]=min(abs(ventre.x-linea_media.x(1).*ones(size(ventre.x))));
dorso.x=[flip(ventre.x(1:I));dorso.x(2:end)];
dorso.y=[flip(ventre.y(1:I));dorso.y(2:end)];
ventre.x=ventre.x(I:end);
ventre.y=ventre.y(I:end);

if nargin >1 && graph==1
    figure
    plot(dorso.x,dorso.y,'b.','HandleVisibility','off')
    axis equal
    grid on
    hold on
    plot(ventre.x,ventre.y,'r.','HandleVisibility','off')
    plot(min(dorso.x):0.0001:min(ventre.x),spl_ventre(min(dorso.x):0.0001:min(ventre.x)),'b-',"HandleVisibility","off")
    plot(min(dorso.x):0.0001:max(dorso.x),spl_dorso(min(dorso.x):0.0001:max(dorso.x)),'b-')
    plot(min(ventre.x):0.0001:max(ventre.x),spl_ventre(min(ventre.x):0.0001:max(ventre.x)),'r')
    plot(linea_media_1.x,linea_media_1.y,'g.-')
    plot(linea_media.x,linea_media.y,'k.-')
    for i=1:size(p.a,1)
        plot([p.a(i,1) p.b(i,1)],[p.a(i,2) p.b(i,2)],'k-',"HandleVisibility","off")
    end
    legend("Dorso","Ventre","Prima iterazione","Linea media")
end
end