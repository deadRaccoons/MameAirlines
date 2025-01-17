PGDMP     1                    r         	   mamelines    9.3.5    9.3.5 Q    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           1262    16389 	   mamelines    DATABASE     {   CREATE DATABASE mamelines WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';
    DROP DATABASE mamelines;
          	   mamelines    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    6            �           0    0    public    ACL     �   REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
                  postgres    false    6            �            3079    12694    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            �           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    186            �            1255    24591    favion()    FUNCTION     �   CREATE FUNCTION favion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin 
        if new.idavion is null then new.idavion = (select max(idavion) from avions) + 1;
        end if;
      return new;
      end;
      $$;
    DROP FUNCTION public.favion();
       public    	   mamelines    false    6    186            �            1255    41113    fhoras()    FUNCTION     f  CREATE FUNCTION fhoras() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    new.horasalida = cast(new.horasalida::time without time zone ||' '|| (select zonahora from ciudads where nombre = new.origen) as time with time zone);
    new.horallegada = (new.horasalida + new.tiempo)::time with time zone at time zone (select zonahora from ciudads where nombre = new.destino);
    new.fechallegada = cast(cast(((select current_date)+ new.horasalida + new.tiempo)::timestamp with time zone at time zone (select zonahora from ciudads where nombre = new.destino) as timestamp) as date);
    return new;
  end;
$$;
    DROP FUNCTION public.fhoras();
       public    	   mamelines    false    6    186            �            1255    24607    fpromocion()    FUNCTION     K  CREATE FUNCTION fpromocion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin 
    new.porcentaje = 1 - new.porcentaje;
    if (select max(idpromocion) from promocion) is null then new.idpromocion = 1;
    return new;
    end if;
    new.idpromocion = (select max(idpromocion) from promocion) + 1;
    return new;
  end;
$$;
 #   DROP FUNCTION public.fpromocion();
       public    	   mamelines    false    186    6            �            1255    24608    fpromocions()    FUNCTION        CREATE FUNCTION fpromocions() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        begin 
          if new.idpromocion is null then new.idpromocion = (select max(idpromocion) from promocions) + 1;
          end if;
        return new;
      end;
    $$;
 $   DROP FUNCTION public.fpromocions();
       public    	   mamelines    false    6    186            �            1255    24609    fusuarios()    FUNCTION     �   CREATE FUNCTION fusuarios() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin 
        if new.idusuario is null then new.idusuario = (select max(idusuario) from usuarios) + 1;
        end if;
        return new;
      end;
      $$;
 "   DROP FUNCTION public.fusuarios();
       public    	   mamelines    false    186    6            �            1255    41114    fvalor()    FUNCTION     .  CREATE FUNCTION fvalor() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin 
    new.fecha = (select current_date);
    if (select max(idvalor) from valor) is null then new.idvalor = 1;
    return null;
    end if;
    new.idvalor = (select max(idvalor) from valor) + 1;
    return new;
  end;
$$;
    DROP FUNCTION public.fvalor();
       public    	   mamelines    false    186    6            �            1255    24610 	   fvalors()    FUNCTION       CREATE FUNCTION fvalors() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin 
    if (select max(idvalor) from valor) is null then new.idvalor = 1;
    return null;
    end if;
    new.idvalor = (select max(idvalor) from valor) + 1;
    return new;
  end;
$$;
     DROP FUNCTION public.fvalors();
       public    	   mamelines    false    186    6            �            1255    24611    fviaje()    FUNCTION     e  CREATE FUNCTION fviaje() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin 
    if new.idviaje is null then new.idviaje = (select max(idviaje) from viaje) + 1;
    end if;
    if new.fechasalida = (select current_date) then new.date = null;
    end if;
    new.distancia = (select distancia from ciudads where new.destino = nombre) - (select distancia from ciudads where new.origen = nombre);
    if new.distancia < 0 then new.distancia = new.distancia * (-1);
    end if;
    new.tiempo = cast((cast(new.distancia as double precision)/ cast(180 as double precision)) as double precision) * cast('1 hour' as interval);
    new.horallegada = new.horasalida + ((cast(new.distancia as double precision)/ cast(180 as double precision)) * cast('01:00' as interval));
    new.fechallegada = new.fechasalida + new.horasalida + ((cast(new.distancia as double precision)/ cast(1080 as double precision)) * cast('01:00' as interval));
    new.costoViaje = new.distancia * (select costomilla from valor);
    update viaje set realizado = 'y' where fechasalida + horasalida <= (select current_timestamp);
    return new;
  end;
$$;
    DROP FUNCTION public.fviaje();
       public    	   mamelines    false    6    186            �            1259    41115    administrador    TABLE     q   CREATE TABLE administrador (
    correo text NOT NULL,
    nombres text NOT NULL,
    apellidos text NOT NULL
);
 !   DROP TABLE public.administrador;
       public      	   mamelines    false    6            �            1259    41121    avion    TABLE       CREATE TABLE avion (
    idavion integer NOT NULL,
    modelo character varying(6) NOT NULL,
    marca text NOT NULL,
    capacidadprimera integer NOT NULL,
    capacidadturista integer NOT NULL,
    disponible character varying(1),
    CONSTRAINT avions_capacidadprimera_check CHECK ((capacidadprimera > 0)),
    CONSTRAINT avions_capacidadturista_check CHECK ((capacidadturista > 0)),
    CONSTRAINT avions_disponible_check CHECK (((disponible)::text = ANY (ARRAY[('y'::character varying)::text, ('n'::character varying)::text])))
);
    DROP TABLE public.avion;
       public      	   mamelines    false    6            �            1259    24612    avions    TABLE       CREATE TABLE avions (
    idavion integer NOT NULL,
    modelo character varying(6) NOT NULL,
    marca text NOT NULL,
    capacidadprimera integer NOT NULL,
    capacidadturista integer NOT NULL,
    disponible character varying(1),
    CONSTRAINT avions_capacidadprimera_check CHECK ((capacidadprimera > 0)),
    CONSTRAINT avions_capacidadturista_check CHECK ((capacidadturista > 0)),
    CONSTRAINT avions_disponible_check CHECK (((disponible)::text = ANY (ARRAY[('y'::character varying)::text, ('n'::character varying)::text])))
);
    DROP TABLE public.avions;
       public      	   mamelines    false    6            �            1259    24621    ciudades    TABLE       CREATE TABLE ciudades (
    nombre text NOT NULL,
    pais text NOT NULL,
    distancia integer,
    descripcion text NOT NULL,
    zonahora text NOT NULL,
    aeropuerto text NOT NULL,
    "IATA" text,
    slug text,
    CONSTRAINT ciudad_distancia_check CHECK ((distancia >= 0))
);
    DROP TABLE public.ciudades;
       public      	   mamelines    false    6            �            1259    41130    horas    TABLE     �   CREATE TABLE horas (
    origen text NOT NULL,
    destino text NOT NULL,
    fechasalida date NOT NULL,
    horasalida time with time zone NOT NULL,
    tiempo interval,
    fechallegada date,
    horallegada time with time zone
);
    DROP TABLE public.horas;
       public      	   mamelines    false    6            �            1259    24628    logins    TABLE     �   CREATE TABLE logins (
    correo text NOT NULL,
    secreto character varying(50) NOT NULL,
    activo character(1) NOT NULL,
    CONSTRAINT logins_activo_check CHECK ((activo = ANY (ARRAY['y'::bpchar, 'n'::bpchar])))
);
    DROP TABLE public.logins;
       public      	   mamelines    false    6            �            1259    57631    promociones    TABLE     �   CREATE TABLE promociones (
    idpromocion integer NOT NULL,
    codigopromocion character varying(10) NOT NULL,
    iniciopromo date NOT NULL,
    finpromo date NOT NULL,
    ciudad text NOT NULL,
    descripcion text NOT NULL,
    slug text NOT NULL
);
    DROP TABLE public.promociones;
       public      	   mamelines    false    6            �            1259    57629    promociones_idpromocion_seq    SEQUENCE     }   CREATE SEQUENCE promociones_idpromocion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.promociones_idpromocion_seq;
       public    	   mamelines    false    185    6            �           0    0    promociones_idpromocion_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE promociones_idpromocion_seq OWNED BY promociones.idpromocion;
            public    	   mamelines    false    184            �            1259    24644    schema_migrations    TABLE     P   CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);
 %   DROP TABLE public.schema_migrations;
       public      	   mamelines    false    6            �            1259    24647    tarjeta    TABLE     �   CREATE TABLE tarjeta (
    notarjeta character varying(16) NOT NULL,
    idusuario integer NOT NULL,
    valor integer,
    saldo numeric(10,2)
);
    DROP TABLE public.tarjeta;
       public      	   mamelines    false    6            �            1259    57569    usuarios    TABLE     �  CREATE TABLE usuarios (
    correo text NOT NULL,
    idusuario integer NOT NULL,
    nombres text NOT NULL,
    apellidopaterno text NOT NULL,
    apellidomaterno text NOT NULL,
    nacionalidad text NOT NULL,
    genero text NOT NULL,
    fechanacimiento date NOT NULL,
    url_imagen text,
    slug text,
    CONSTRAINT usuarios_genero_check CHECK ((genero = ANY (ARRAY[('H'::character varying)::text, ('M'::character varying)::text])))
);
    DROP TABLE public.usuarios;
       public      	   mamelines    false    6            �            1259    57567    usuarios_idusuario_seq    SEQUENCE     x   CREATE SEQUENCE usuarios_idusuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.usuarios_idusuario_seq;
       public    	   mamelines    false    183    6            �           0    0    usuarios_idusuario_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE usuarios_idusuario_seq OWNED BY usuarios.idusuario;
            public    	   mamelines    false    182            �            1259    24657    valor    TABLE     �   CREATE TABLE valor (
    idvalor integer NOT NULL,
    costomilla double precision NOT NULL,
    tipomoneda text NOT NULL,
    tipomedida text NOT NULL,
    CONSTRAINT valor_idvalor_check CHECK (((idvalor > 0) AND (idvalor < 2)))
);
    DROP TABLE public.valor;
       public      	   mamelines    false    6            �            1259    24664    viajes    TABLE     #  CREATE TABLE viajes (
    idviaje integer NOT NULL,
    origen text NOT NULL,
    destino text NOT NULL,
    fechasalida date NOT NULL,
    horasalida time without time zone NOT NULL,
    fechallegada date,
    horallegada time without time zone,
    distancia integer,
    idavion integer NOT NULL,
    costoviaje double precision,
    realizado character(1) NOT NULL,
    tiempo interval,
    CONSTRAINT viaje_check CHECK ((destino <> origen)),
    CONSTRAINT viaje_realizado_check CHECK ((realizado = ANY (ARRAY['y'::bpchar, 'n'::bpchar])))
);
    DROP TABLE public.viajes;
       public      	   mamelines    false    6            �            1259    24717    vuelos    TABLE     �   CREATE TABLE vuelos (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
    DROP TABLE public.vuelos;
       public      	   mamelines    false    6            �            1259    24715    vuelos_id_seq    SEQUENCE     o   CREATE SEQUENCE vuelos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.vuelos_id_seq;
       public    	   mamelines    false    6    178            �           0    0    vuelos_id_seq    SEQUENCE OWNED BY     1   ALTER SEQUENCE vuelos_id_seq OWNED BY vuelos.id;
            public    	   mamelines    false    177            "           2604    57634    idpromocion    DEFAULT     t   ALTER TABLE ONLY promociones ALTER COLUMN idpromocion SET DEFAULT nextval('promociones_idpromocion_seq'::regclass);
 F   ALTER TABLE public.promociones ALTER COLUMN idpromocion DROP DEFAULT;
       public    	   mamelines    false    184    185    185                        2604    57572 	   idusuario    DEFAULT     j   ALTER TABLE ONLY usuarios ALTER COLUMN idusuario SET DEFAULT nextval('usuarios_idusuario_seq'::regclass);
 A   ALTER TABLE public.usuarios ALTER COLUMN idusuario DROP DEFAULT;
       public    	   mamelines    false    182    183    183                       2604    41166    id    DEFAULT     X   ALTER TABLE ONLY vuelos ALTER COLUMN id SET DEFAULT nextval('vuelos_id_seq'::regclass);
 8   ALTER TABLE public.vuelos ALTER COLUMN id DROP DEFAULT;
       public    	   mamelines    false    177    178    178            �          0    41115    administrador 
   TABLE DATA               <   COPY administrador (correo, nombres, apellidos) FROM stdin;
    public    	   mamelines    false    179   Lg       �          0    41121    avion 
   TABLE DATA               `   COPY avion (idavion, modelo, marca, capacidadprimera, capacidadturista, disponible) FROM stdin;
    public    	   mamelines    false    180   ig       �          0    24612    avions 
   TABLE DATA               a   COPY avions (idavion, modelo, marca, capacidadprimera, capacidadturista, disponible) FROM stdin;
    public    	   mamelines    false    170   �h       �          0    24621    ciudades 
   TABLE DATA               e   COPY ciudades (nombre, pais, distancia, descripcion, zonahora, aeropuerto, "IATA", slug) FROM stdin;
    public    	   mamelines    false    171   �i       �          0    41130    horas 
   TABLE DATA               e   COPY horas (origen, destino, fechasalida, horasalida, tiempo, fechallegada, horallegada) FROM stdin;
    public    	   mamelines    false    181   'm       �          0    24628    logins 
   TABLE DATA               2   COPY logins (correo, secreto, activo) FROM stdin;
    public    	   mamelines    false    172   �m       �          0    57631    promociones 
   TABLE DATA               n   COPY promociones (idpromocion, codigopromocion, iniciopromo, finpromo, ciudad, descripcion, slug) FROM stdin;
    public    	   mamelines    false    185   \n       �           0    0    promociones_idpromocion_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('promociones_idpromocion_seq', 1, false);
            public    	   mamelines    false    184            �          0    24644    schema_migrations 
   TABLE DATA               -   COPY schema_migrations (version) FROM stdin;
    public    	   mamelines    false    173   yn       �          0    24647    tarjeta 
   TABLE DATA               >   COPY tarjeta (notarjeta, idusuario, valor, saldo) FROM stdin;
    public    	   mamelines    false    174   �n       �          0    57569    usuarios 
   TABLE DATA               �   COPY usuarios (correo, idusuario, nombres, apellidopaterno, apellidomaterno, nacionalidad, genero, fechanacimiento, url_imagen, slug) FROM stdin;
    public    	   mamelines    false    183   o       �           0    0    usuarios_idusuario_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('usuarios_idusuario_seq', 6, true);
            public    	   mamelines    false    182            �          0    24657    valor 
   TABLE DATA               E   COPY valor (idvalor, costomilla, tipomoneda, tipomedida) FROM stdin;
    public    	   mamelines    false    175   �o       �          0    24664    viajes 
   TABLE DATA               �   COPY viajes (idviaje, origen, destino, fechasalida, horasalida, fechallegada, horallegada, distancia, idavion, costoviaje, realizado, tiempo) FROM stdin;
    public    	   mamelines    false    176   �o       �          0    24717    vuelos 
   TABLE DATA               5   COPY vuelos (id, created_at, updated_at) FROM stdin;
    public    	   mamelines    false    178   �p       �           0    0    vuelos_id_seq    SEQUENCE SET     4   SELECT pg_catalog.setval('vuelos_id_seq', 1, true);
            public    	   mamelines    false    177            3           2606    41168    adiministradorc 
   CONSTRAINT     X   ALTER TABLE ONLY administrador
    ADD CONSTRAINT adiministradorc PRIMARY KEY (correo);
 G   ALTER TABLE ONLY public.administrador DROP CONSTRAINT adiministradorc;
       public      	   mamelines    false    179    179            5           2606    41138    adminc 
   CONSTRAINT     J   ALTER TABLE ONLY administrador
    ADD CONSTRAINT adminc UNIQUE (correo);
 >   ALTER TABLE ONLY public.administrador DROP CONSTRAINT adminc;
       public      	   mamelines    false    179    179            7           2606    41140    administrador_correo_key 
   CONSTRAINT     \   ALTER TABLE ONLY administrador
    ADD CONSTRAINT administrador_correo_key UNIQUE (correo);
 P   ALTER TABLE ONLY public.administrador DROP CONSTRAINT administrador_correo_key;
       public      	   mamelines    false    179    179            $           2606    24673    avions_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY avions
    ADD CONSTRAINT avions_pkey PRIMARY KEY (idavion);
 <   ALTER TABLE ONLY public.avions DROP CONSTRAINT avions_pkey;
       public      	   mamelines    false    170    170            &           2606    24675    ciudadc 
   CONSTRAINT     K   ALTER TABLE ONLY ciudades
    ADD CONSTRAINT ciudadc PRIMARY KEY (nombre);
 :   ALTER TABLE ONLY public.ciudades DROP CONSTRAINT ciudadc;
       public      	   mamelines    false    171    171            9           2606    41170    horasc 
   CONSTRAINT     i   ALTER TABLE ONLY horas
    ADD CONSTRAINT horasc PRIMARY KEY (origen, destino, fechasalida, horasalida);
 6   ALTER TABLE ONLY public.horas DROP CONSTRAINT horasc;
       public      	   mamelines    false    181    181    181    181    181            (           2606    24677    loginc 
   CONSTRAINT     H   ALTER TABLE ONLY logins
    ADD CONSTRAINT loginc PRIMARY KEY (correo);
 7   ALTER TABLE ONLY public.logins DROP CONSTRAINT loginc;
       public      	   mamelines    false    172    172            =           2606    57639    proomocionsc 
   CONSTRAINT     X   ALTER TABLE ONLY promociones
    ADD CONSTRAINT proomocionsc PRIMARY KEY (idpromocion);
 B   ALTER TABLE ONLY public.promociones DROP CONSTRAINT proomocionsc;
       public      	   mamelines    false    185    185            +           2606    24685    tarjetas_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY tarjeta
    ADD CONSTRAINT tarjetas_pkey PRIMARY KEY (notarjeta);
 ?   ALTER TABLE ONLY public.tarjeta DROP CONSTRAINT tarjetas_pkey;
       public      	   mamelines    false    174    174            ;           2606    57578 	   usuariosc 
   CONSTRAINT     P   ALTER TABLE ONLY usuarios
    ADD CONSTRAINT usuariosc PRIMARY KEY (idusuario);
 <   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT usuariosc;
       public      	   mamelines    false    183    183            -           2606    24689 
   valor_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY valor
    ADD CONSTRAINT valor_pkey PRIMARY KEY (idvalor);
 :   ALTER TABLE ONLY public.valor DROP CONSTRAINT valor_pkey;
       public      	   mamelines    false    175    175            /           2606    24691    viajec 
   CONSTRAINT     I   ALTER TABLE ONLY viajes
    ADD CONSTRAINT viajec PRIMARY KEY (idviaje);
 7   ALTER TABLE ONLY public.viajes DROP CONSTRAINT viajec;
       public      	   mamelines    false    176    176            1           2606    24722    vuelos_pkey 
   CONSTRAINT     I   ALTER TABLE ONLY vuelos
    ADD CONSTRAINT vuelos_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.vuelos DROP CONSTRAINT vuelos_pkey;
       public      	   mamelines    false    178    178            )           1259    24692    unique_schema_migrations    INDEX     Y   CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);
 ,   DROP INDEX public.unique_schema_migrations;
       public      	   mamelines    false    173            �           2618    41173    rviaje    RULE     B   CREATE RULE rviaje AS
    ON UPDATE TO viajes DO INSTEAD NOTHING;
 #   DROP RULE rviaje ON public.viajes;
       public    	   mamelines    false    176    176    176            D           2620    24693    tavion    TRIGGER     W   CREATE TRIGGER tavion BEFORE INSERT ON avions FOR EACH ROW EXECUTE PROCEDURE favion();
 &   DROP TRIGGER tavion ON public.avions;
       public    	   mamelines    false    199    170            H           2620    41141    tavion    TRIGGER     V   CREATE TRIGGER tavion BEFORE INSERT ON avion FOR EACH ROW EXECUTE PROCEDURE favion();
 %   DROP TRIGGER tavion ON public.avion;
       public    	   mamelines    false    199    180            I           2620    41142    thoras    TRIGGER     V   CREATE TRIGGER thoras BEFORE INSERT ON horas FOR EACH ROW EXECUTE PROCEDURE fhoras();
 %   DROP TRIGGER thoras ON public.horas;
       public    	   mamelines    false    205    181            F           2620    41145    tvalor    TRIGGER     V   CREATE TRIGGER tvalor BEFORE INSERT ON valor FOR EACH ROW EXECUTE PROCEDURE fvalor();
 %   DROP TRIGGER tvalor ON public.valor;
       public    	   mamelines    false    175    206            E           2620    24697    tvalors    TRIGGER     X   CREATE TRIGGER tvalors BEFORE INSERT ON valor FOR EACH ROW EXECUTE PROCEDURE fvalors();
 &   DROP TRIGGER tvalors ON public.valor;
       public    	   mamelines    false    175    203            G           2620    24698    tviaje    TRIGGER     W   CREATE TRIGGER tviaje BEFORE INSERT ON viajes FOR EACH ROW EXECUTE PROCEDURE fviaje();
 &   DROP TRIGGER tviaje ON public.viajes;
       public    	   mamelines    false    204    176            @           2606    41146    administrador_correo_fkey    FK CONSTRAINT     |   ALTER TABLE ONLY administrador
    ADD CONSTRAINT administrador_correo_fkey FOREIGN KEY (correo) REFERENCES logins(correo);
 Q   ALTER TABLE ONLY public.administrador DROP CONSTRAINT administrador_correo_fkey;
       public    	   mamelines    false    179    2856    172            A           2606    41151    horas_destino_fkey    FK CONSTRAINT     p   ALTER TABLE ONLY horas
    ADD CONSTRAINT horas_destino_fkey FOREIGN KEY (destino) REFERENCES ciudades(nombre);
 B   ALTER TABLE ONLY public.horas DROP CONSTRAINT horas_destino_fkey;
       public    	   mamelines    false    2854    171    181            B           2606    41156    horas_origen_fkey    FK CONSTRAINT     n   ALTER TABLE ONLY horas
    ADD CONSTRAINT horas_origen_fkey FOREIGN KEY (origen) REFERENCES ciudades(nombre);
 A   ALTER TABLE ONLY public.horas DROP CONSTRAINT horas_origen_fkey;
       public    	   mamelines    false    2854    171    181            C           2606    57579    usuarios_correo_fkey    FK CONSTRAINT     r   ALTER TABLE ONLY usuarios
    ADD CONSTRAINT usuarios_correo_fkey FOREIGN KEY (correo) REFERENCES logins(correo);
 G   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT usuarios_correo_fkey;
       public    	   mamelines    false    172    2856    183            >           2606    41180    viaje_destino_fkey    FK CONSTRAINT     q   ALTER TABLE ONLY viajes
    ADD CONSTRAINT viaje_destino_fkey FOREIGN KEY (destino) REFERENCES ciudades(nombre);
 C   ALTER TABLE ONLY public.viajes DROP CONSTRAINT viaje_destino_fkey;
       public    	   mamelines    false    171    2854    176            ?           2606    24709    viaje_idavion_fkey    FK CONSTRAINT     p   ALTER TABLE ONLY viajes
    ADD CONSTRAINT viaje_idavion_fkey FOREIGN KEY (idavion) REFERENCES avions(idavion);
 C   ALTER TABLE ONLY public.viajes DROP CONSTRAINT viaje_idavion_fkey;
       public    	   mamelines    false    176    170    2852            �      x������ � �      �   2  x��R�n�0����0��4�q�"�Ю]�DH8R!'��%m�{&w���@�g)�.��)�~���DA�m�΀�j!r��f�Œ���uX��R�4����H��x�Zf���� s�4��쏍w��}����o��(-�@�g��$���h�Q�`�,w��K�� y��z�kb��U=r��SeX�^�����4����d�r�+�xw����p�q�[7\b��kL��H$I���6�:bc��ڣ]D��W�rY`��H��)_��p�]�ep�9;@67�<�����l>_�(�[:      �   '  x�mR�n�0</_�P���>ȥJzh����J��]��R���P����f�3�#L��`�p|�P��R��2������ b
��ȁrZ`bKF ZQ�a!�HQ���b"��L�f���
� s��M���;g�!n��2t�K��~�Ћ��o��E4դA0o	
��{翥�4f���Cg��sqU�\%v��+_��x�j�M�-'��ƻSm��gס���5f����G"Mj;v�����՝�6 *ؽ�"���'Jo���=��8.����#d�|�DQ�}"�j      �   5  x���͒�6�ϭ��H<^<�#0x�]3�=[{ȥ�h�W�V��<J�{�uo~�����Lr�*�[?���j?i��Q)4֪��iLxe�H��
<o����2x����Z��keŲ�Zb*���ʸ�V��_ �����eE���T�a�޽�aD�A��i.N�*,_��5<G����!�/x�R �O��ɪ=�o��Q,h����W������̙u{��k�⯡ҙJ�͛E������o�6.R�"p����6���}w��(��@�;�p�`�,M��9�����*�Ȱ����Q���@����v�풛E��$�F����k7q��f?@f�,*��� :�S��^����J#�cxa�&�EU�e��k�ǆ��N���3��_c}���Za���#S��5�5�ٍ�0���(��(�{���f����uàח�~�~�-ͩ��n�{�.����~͞J8Dۋ&/�����yK�J�5} ̍�=w>�Y�wpQG
�\���l��b��\�hء�ư}�/�Atl�_齫�i�ܽ�ژ��V�^I�3E(MϠ8�W��;���eÀK������U�qɞ)��vXx7]��K.O/�l�؆i�t�v]����.^U:ē +�\k��dl�L���As4V� Ǚ{��y����o� O��.�-��C���L�����R�*�m��@�����nz�_��(,c��Ga����v�(��DcН>ZQ:��9B �KN#m��@m C%Hw�)�ѭiw���[?Ta�Q����5��t�ԙ���.��}§!���c�_�h�      �   �   x���M
�0��ur
��a~2I3K��n�vQA�J�Ë�B��Hu�晏�í;t���잏�p��m=gC��F�	&eV�RÍ��2(���QXd����8�|�9S}`���1"ŏ,ؒ-�Sv���E��ie;/��g3E.���6}�?Q?W���6L��c��dg��w���`n9      �   b   x����	�0 ���4Jj�9���I�H"(�n�
����sib��Ý����!G�VA?f�>�0�T�b���Pz���U\���1P��J2Y\ ��Df      �      x������ � �      �   a   x�M˱1B�\�� +��뿎��V���"��:�$͗�q�ڗ���j�R�נ;;NߐZ�,�r�����Hr��:�ՃE��^�����'"�	38      �      x������ � �      �   �   x�u���0��s������C�p���ٚ��I�O/#�=���rΤ�g�Px;��P��z�f2�R�����N8lnZr��^Y��X��1�-����5*�/fZ�<��|��RRP?�a�ʿ��$�X����ﶰ��醣XS�>[�S.%�xEuQw      �   #   x�3�4�326@��)�99�E���@�+F��� �<	       �   �   x���Kn�0���\ k^�'�v��A6tU�=��b8�*b	�4 F^���X�~��_�q���ݦ;l��yHI�DeŌXV��,����|�iY� �MN���W9�>�fZi�g�1[�؛�i�;%����4Rx�a���a	g�ñɕ� (YR��CA��\DB�Qn���n���������Cw�ߛ��Zf���N�shDr�ᆌ(3�hy7�h����q;��!�      �   ,   x�3�4204�54�5�T0��21�20�347�43�#����� c�D     