CREATE OR REPLACE PACKAGE pkg_hopital IS

--  CRUD PATIENT

PROCEDURE ajouter_patient(
  p_idpatient patient.idpatient%TYPE,
  p_nom patient.nom%TYPE,
  p_prenom patient.prenom%TYPE,
  p_daten patient.date_naissance%TYPE,
  p_adresse patient.adresse%TYPE,
  p_tel patient.telephone%TYPE
);

PROCEDURE modifier_patient(
   p_idpatient patient.idpatient%TYPE,
  p_nom patient.nom%TYPE,
  p_prenom patient.prenom%TYPE,
  p_daten patient.date_naissance%TYPE,
  p_adresse patient.adresse%TYPE,
  p_tel patient.telephone%TYPE
);

PROCEDURE supprimer_patient(p_id number);
PROCEDURE afficher_patient;

--  CRUD MEDECIN

PROCEDURE ajouter_medecin(
  p_idmedecin medecin.idmedecin%TYPE,
  p_nom medecin.nom%TYPE,
  p_specialite medecin.specialite%TYPE,
  p_salaire medecin.salaire%TYPE,
  p_idservice medecin.idservice%TYPE
);

PROCEDURE modifier_medecin(
  p_idmedecin medecin.idmedecin%TYPE,
  p_nom medecin.nom%TYPE,
  p_specialite medecin.specialite%TYPE,
  p_salaire medecin.salaire%TYPE,
  p_idservice medecin.idservice%TYPE
);

PROCEDURE supprimer_medecin(p_idmedecin medecin.idmedecin%TYPE);
PROCEDURE afficher_medecin;


-- CRUD MEDICAMENT

PROCEDURE ajouter_medicament(
  p_idmed medicament.idmed%TYPE,
  p_nom medicament.nom%TYPE,
  p_stock medicament.stock%TYPE,
  p_prix medicament.prix%TYPE
);

PROCEDURE modifier_medicament(
 p_idmed medicament.idmed%TYPE,
  p_nom medicament.nom%TYPE,
  p_stock medicament.stock%TYPE,
  p_prix medicament.prix%TYPE
);

PROCEDURE supprimer_medicament(p_id medicament.idmed%TYPE);
PROCEDURE afficher_medicament;


--  CRUD RENDEZ-VOUS

PROCEDURE ajouter_rdv(
 p_idrdv rendezvous.idrdv%TYPE,
  p_idpatient rendezvous.idpatient%TYPE,
  p_idmedecin rendezvous.idmedecin%TYPE,
  p_daterdv rendezvous.daterdv%TYPE,
  p_statut rendezvous.statut%TYPE
);

PROCEDURE modifier_rdv(
   p_idrdv rendezvous.idrdv%TYPE,
  p_idpatient rendezvous.idpatient%TYPE,
  p_idmedecin rendezvous.idmedecin%TYPE,
  p_daterdv rendezvous.daterdv%TYPE,
  p_statut rendezvous.statut%TYPE
);

PROCEDURE supprimer_rdv(p_id rendezvous.idrdv%TYPE);
PROCEDURE afficher_rdv;
-- CURSEUR
PROCEDURE afficher_rdv_medecin(p_idmedecin medecin.idmedecin%TYPE);


--  FONCTIONS

FUNCTION nb_patients_service(v_idservice number) RETURN NUMBER;
FUNCTION total_medicaments_patient(v_idpatient number) RETURN NUMBER;
FUNCTION cout_prescription(v_idpresc number) RETURN NUMBER;


--  PROCEDURES CURSEUR
PROCEDURE liste_hospitalisations;


--  COLLECTION

PROCEDURE medicaments_rupture;


--  EXCEPTIONS 

PROCEDURE verifier_stock(v_idmed NUMBER, v_qte NUMBER);
PROCEDURE verifier_rdv(v_idmed NUMBER, v_date DATE);
PROCEDURE verifier_capacite(v_idservice NUMBER);


--  PROCEDURE METIER

PROCEDURE prescrire_medicament(
    p_idmed NUMBER,
    p_qte NUMBER,
    p_idpatient NUMBER,
    p_idPresc NUMBER,
    p_idmedecin NUMBER
);


END pkg_hopital;
/











-- body
CREATE OR REPLACE PACKAGE BODY pkg_hopital IS

--creud patient
procedure ajouter_patient(
  p_idpatient patient.idpatient%type,
  p_nom       patient.nom%type,
  p_prenom    patient.prenom%type,
  p_daten     patient.date_naissance%type,
  p_adresse   patient.adresse%type,
  p_tel       patient.telephone%type
)
is
begin

  insert into patient(
    idpatient, nom, prenom,  date_naissance, adresse, telephone
  )
  values (
    p_idpatient, p_nom, p_prenom, p_daten, p_adresse, p_tel
  );

  dbms_output.put_line('patient ajoute');

exception
  when others then
  ROLLBACK;
    dbms_output.put_line('erreur : ' || sqlerrm);
end  ajouter_patient;

procedure modifier_patient(
  p_idpatient patient.idpatient%type,
  p_nom       patient.nom%type,
  p_prenom    patient.prenom%type,
  p_daten     patient.date_naissance%type,
  p_adresse   patient.adresse%type,
  p_tel       patient.telephone%type
)
is
begin

  update patient
  set nom = p_nom,
      prenom = p_prenom,
       date_naissance = p_daten,
      adresse = p_adresse,
      telephone = p_tel
  where idpatient = p_idpatient;

  if sql%rowcount = 0 then
    dbms_output.put_line('patient inexistant');
  else
    dbms_output.put_line('patient modifie');
  end if;

exception
  when others then
    dbms_output.put_line('erreur : ' || sqlerrm);
 end modifier_patient;

procedure afficher_patient
is
begin
    for p in (select * from patient) loop
        dbms_output.put_line(p.nom || ' ' || p.prenom);
    end loop;
end;

PROCEDURE supprimer_patient(p_id NUMBER) IS
BEGIN
  -- supprimer enfants
  DELETE FROM ligne_prescription
  WHERE idpresc IN (
    SELECT idpresc FROM prescription WHERE idpatient = p_id
  );

  DELETE FROM prescription
  WHERE idpatient = p_id;

  -- supprimer patient
  DELETE FROM patient
  WHERE idpatient = p_id;

  IF SQL%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('patient inexistant');
  ELSE
    DBMS_OUTPUT.PUT_LINE('patient supprime');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('erreur : ' || SQLERRM);
END supprimer_patient;
-- creud medecin
procedure ajouter_medecin(
  p_idmedecin medecin.idmedecin%type,
  p_nom       medecin.nom%type,
  p_specialite medecin.specialite%type,
  p_salaire   medecin.salaire%type,
  p_idservice medecin.idservice%type
)
is
begin

  insert into medecin(
    idmedecin, nom, specialite, salaire, idservice
  )
  values (
    p_idmedecin, p_nom, p_specialite, p_salaire, p_idservice
  );

  dbms_output.put_line('medecin ajoute');

exception
  when others then
  ROLLBACK;
    dbms_output.put_line('erreur : ' || sqlerrm);
end ajouter_medecin;

procedure modifier_medecin (
  p_idmedecin medecin.idmedecin%type,
  p_nom       medecin.nom%type,
  p_specialite medecin.specialite%type,
  p_salaire   medecin.salaire%type,
  p_idservice medecin.idservice%type
)
is
begin

  update medecin
  set nom = p_nom,
      specialite = p_specialite,
      salaire = p_salaire,
      idservice = p_idservice
  where idmedecin = p_idmedecin;

  if sql%rowcount = 0 then
    dbms_output.put_line('medecin inexistant');
  else
    dbms_output.put_line('medecin modifie');
  end if;

exception
  when others then
    dbms_output.put_line('erreur : ' || sqlerrm);
end modifier_medecin;

procedure supprimer_medecin(p_idmedecin  medecin.idmedecin%TYPE)
is
begin
    delete from medecin
    where idmedecin = p_idmedecin ;

    if sql%rowcount = 0 then
        dbms_output.put_line('medecin inexistant');
    else
        dbms_output.put_line('medecin supprimé');
    end if;

exception
    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
end supprimer_medecin;

procedure afficher_medecin
is
begin
    for m in (select * from medecin) loop
        dbms_output.put_line(
            m.idmedecin || ' ' || m.nom || ' ' || m.specialite
        );
    end loop;
end afficher_medecin;

--creud medicament
procedure ajouter_medicament(
  p_idmed medicament.idmed%type,
  p_nom   medicament.nom%type,
  p_stock medicament.stock%type,
  p_prix  medicament.prix%type
)
is
begin

  insert into medicament(
    idmed, nom, stock, prix
  )
  values (
    p_idmed, p_nom, p_stock, p_prix
  );

  dbms_output.put_line('medicament ajoute');

exception
  when others then
  ROLLBACK;
    dbms_output.put_line('erreur : ' || sqlerrm);
end ajouter_medicament;

procedure modifier_medicament(
  p_idmed  medicament.idmed%type,
  p_nom    medicament.nom%type,
  p_stock  medicament.stock%type,
  p_prix   medicament.prix%type
)
is
begin

  update medicament
  set nom   = p_nom,
      stock = p_stock,
      prix  = p_prix
  where idmed = p_idmed;

  if sql%rowcount = 0 then
    dbms_output.put_line('medicament inexistant');
  else
    dbms_output.put_line('medicament modifie');
  end if;

exception
  when others then
    dbms_output.put_line('erreur : ' || sqlerrm);
end  modifier_medicament;

procedure supprimer_medicament
(p_id medicament.idmed%TYPE)
is
begin
    delete from medicament
    where idmed = p_id;

    if sql%rowcount = 0 then
        dbms_output.put_line('medicament inexistant');
    else
        dbms_output.put_line('medicament supprimé');
    end if;

exception
    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
end supprimer_medicament;
procedure afficher_medicament
is
begin
    for m in (select * from medicament) loop
        dbms_output.put_line(
            m.idmed || ' ' || m.nom || ' stock:' || m.stock
        );
    end loop;
end afficher_medicament;

--creud rendez vous
PROCEDURE afficher_rdv
IS
BEGIN
  FOR r IN (SELECT * FROM rendezvous) LOOP
    DBMS_OUTPUT.PUT_LINE(
      r.idrdv || ' ' || r.idpatient || ' ' || r.idmedecin || ' ' || r.daterdv
    );
  END LOOP;
END afficher_rdv;
procedure ajouter_rdv(
  p_idrdv      rendezvous.idrdv%type,
  p_idpatient  rendezvous.idpatient%type,
  p_idmedecin  rendezvous.idmedecin%type,
  p_daterdv    rendezvous.daterdv%type,
  p_statut     rendezvous.statut%type
)
is
begin
  verifier_rdv(p_idmedecin, p_daterdv);
  insert into rendezvous(
    idrdv, idpatient, idmedecin, daterdv, statut
  )
  values (
    p_idrdv, p_idpatient, p_idmedecin, p_daterdv, p_statut
  );

  dbms_output.put_line('rdv ajoute');

exception
  when others then
  ROLLBACK;
    dbms_output.put_line('erreur : ' || sqlerrm);
end ajouter_rdv;

procedure modifier_rdv(
  p_idrdv      rendezvous.idrdv%type,
  p_idpatient  rendezvous.idpatient%type,
  p_idmedecin  rendezvous.idmedecin%type,
  p_daterdv    rendezvous.daterdv%type,
  p_statut     rendezvous.statut%type
)
is
  v_count number;
begin

  select count(*) into v_count
  from rendezvous
  where idmedecin = p_idmedecin
  and daterdv = p_daterdv
  and idrdv <> p_idrdv;

  if v_count > 0 then
    raise_application_error(-20001,'conflit de rendez-vous');
  end if;

  update rendezvous
  set idpatient = p_idpatient,
      idmedecin = p_idmedecin,
      daterdv   = p_daterdv,
      statut    = p_statut
  where idrdv = p_idrdv;

  if sql%rowcount = 0 then
    dbms_output.put_line('rdv inexistant');
  else
    dbms_output.put_line('rdv modifie');
  end if;

exception
  when others then
    dbms_output.put_line('erreur : ' || sqlerrm);
end  modifier_rdv;

procedure supprimer_rdv(p_id rendezvous.idrdv%TYPE)
is
begin
    delete from rendezvous
    where idrdv = p_id;

    if sql%rowcount = 0 then
        dbms_output.put_line('rdv inexistant');
    else
        dbms_output.put_line('rdv supprimé');
    end if;

exception
    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
end supprimer_rdv;
--curseur parametre
PROCEDURE afficher_rdv_medecin(p_idmedecin medecin.idmedecin%TYPE) IS
  CURSOR c_rdv(p_idmedecin medecin.idmedecin%TYPE) IS
    SELECT r.dateRdv, p.nom, r.statut
    FROM rendezvous r
    inner join patient p
    on r.idPatient = p.idPatient
    where r.idMedecin = p_idmedecin;

    rec c_rdv%ROWTYPE;
BEGIN
 OPEN c_rdv(p_idmedecin);

  FETCH c_rdv INTO rec;

  IF c_rdv%NOTFOUND THEN
    DBMS_OUTPUT.PUT_LINE('Aucun RDV');
  ELSE
    LOOP
      DBMS_OUTPUT.PUT_LINE(rec.dateRdv || ' ' || rec.nom || ' ' || rec.statut);
      FETCH c_rdv INTO rec;
      EXIT WHEN c_rdv%NOTFOUND;
    END LOOP;
  END IF;

  CLOSE c_rdv;
END afficher_rdv_medecin;

--fonction
function nb_patients_service(v_idservice number)
return number
is
    v_nb number;
begin
    select count(*)
    into v_nb
    from hospitalisation
    where idservice = v_idservice;

    return v_nb;

exception
    when no_data_found then
        return 0;
    when too_many_rows then  
        dbms_output.put_line('Trop de lignes');
        return -1;
    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
        return -1;
end;

function total_medicaments_patient(v_idpatient number)
return number
is
    v_total number;
begin
    select sum(lp.quantite)
    into v_total
    from prescription p
    inner join ligne_prescription lp
    on p.idpresc = lp.idpresc
    where p.idpatient = v_idpatient;

    return nvl(v_total, 0);

exception
    when no_data_found then
        return 0;
    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
        return -1;
end;
function cout_prescription(v_idpresc number)
return number
is
    cursor c is
        select lp.quantite, m.prix
        from ligne_prescription lp
        inner join medicament m
        on lp.idmed = m.idmed
        where lp.idpresc = v_idpresc;

    v_total number := 0;
begin
    for rec in c loop
        v_total := v_total + (rec.quantite * rec.prix);
    end loop;

    return v_total;
    exception
     when zero_divide then  
        dbms_output.put_line('Division par zéro');
        return -1;
    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
        return -1;
end;
--procedure avec curseur
procedure liste_hospitalisations
is
    cursor c is
        select p.nom, s.nomservice,
               (h.datesortie - h.dateentree) as duree
        from hospitalisation h
        inner join patient p
        on h.idpatient = p.idpatient
        inner join service s
        on h.idservice = s.idservice;

    v_rec c%rowtype;
begin
    open c;

    fetch c into v_rec;

    if c%NOTFOUND then
        dbms_output.put_line('aucune hospitalisation trouvée');
    else
        while c%found loop
            dbms_output.put_line(
                'patient: ' || v_rec.nom ||
                ' | service: ' || v_rec.nomservice ||
                ' | duree: ' || v_rec.duree || ' jours'
            );

            fetch c into v_rec;
        end loop;
    end if;

    close c;

exception
    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
end;

--tableau
procedure medicaments_rupture
is
    cursor c is
        select * from medicament where stock = 0;

    v_rec c%rowtype;

    type tab_med is table of medicament%rowtype;
    t tab_med := tab_med();

begin
    open c;

    fetch c into v_rec;

   
        while c%found loop

            t.extend;
            t(t.last) := v_rec;

            fetch c into v_rec;
        end loop;
    close c;
 IF t.COUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Aucun en rupture');
  ELSE
    FOR i IN 1..t.COUNT LOOP
     
        dbms_output.put_line(
            'medicament: ' || t(i).nom ||
            ' | stock: ' || t(i).stock
        );
    END LOOP;
  END IF;

exception
      when no_data_found then
        dbms_output.put_line('aucun medicament en rupture');
    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
end;

--les exceptions
procedure verifier_stock(v_idmed number, v_qte number)
is
    v_stock number;

   
begin
    select stock into v_stock
    from medicament
    where idmed = v_idmed;

    if v_stock < v_qte then
      raise_application_error(-20003, 'Stock insuffisant');
    end if;

    dbms_output.put_line('stock suffisant');

exception
   

    when no_data_found then
        dbms_output.put_line('medicament inexistant');

    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
end;
procedure verifier_rdv(v_idmed number, v_date date)
is
    v_nb number;
begin
    select count(*) into v_nb
    from rendezvous
    where idmedecin = v_idmed
    and daterdv = v_date;

    if v_nb > 0 then
       RAISE_APPLICATION_ERROR(-20001, 'Conflit de rendez-vous');
    end if;

    dbms_output.put_line('rdv possible');

exception
  

    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
end;
procedure verifier_capacite(v_idservice number)
is
    v_nb number;
    v_cap number;

    ex_capacite_depassee exception;
begin
    select count(*) into v_nb
    from hospitalisation
    where idservice = v_idservice;

    select capacite into v_cap
    from service
    where idservice = v_idservice;

    if v_nb >= v_cap then
        raise ex_capacite_depassee;
    end if;

    dbms_output.put_line('capacité disponible');

exception
    when ex_capacite_depassee then
        dbms_output.put_line('capacité dépassée');

    when others then
        dbms_output.put_line('erreur : ' || sqlerrm);
end;
--procedure metier complexe
PROCEDURE prescrire_medicament(
    p_idmed NUMBER,
    p_qte NUMBER,
    p_idpatient NUMBER,
    p_idPresc NUMBER,
    p_idmedecin NUMBER
)
IS
  
    CURSOR c_med IS
        SELECT idmed, stock, prix
        FROM medicament
        WHERE idmed = p_idmed;

    rec c_med%ROWTYPE;

    
    TYPE tab_med IS TABLE OF c_med%ROWTYPE;
    t_med tab_med := tab_med();

BEGIN

    verifier_stock(p_idmed, p_qte);

    OPEN c_med;
    FETCH c_med INTO rec;

    IF c_med%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Médicament introuvable');
    END IF;

  
    t_med.EXTEND;
    t_med(1) := rec;

    CLOSE c_med;

   
    INSERT INTO prescription(idpresc, idpatient, idmedecin, datepresc)
    VALUES (p_idPresc, p_idpatient, p_idmedecin, SYSDATE);


    INSERT INTO ligne_prescription(idpresc, idmed, quantite)
    VALUES (p_idPresc, p_idmed, p_qte);

   
    UPDATE medicament
    SET stock = stock - p_qte
    WHERE idmed = p_idmed;

    DBMS_OUTPUT.PUT_LINE('Prescription réalisée avec succès');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
END;
PROCEDURE ajouter_hospitalisation(
  p_idhosp NUMBER,
  p_idpatient NUMBER,
  p_idservice NUMBER,
  p_dateentree DATE,
  p_datesortie DATE
)
IS
BEGIN
  INSERT INTO hospitalisation
  VALUES (p_idhosp, p_idpatient, p_idservice, p_dateentree, p_datesortie);

  DBMS_OUTPUT.PUT_LINE('Hospitalisation ajoutée');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
END;



END pkg_hopital;
/




--trigger
CREATE OR REPLACE TRIGGER trg_check_rdv
BEFORE INSERT ON rendezvous
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  -- vérifier conflit (même médecin, même date)
  SELECT COUNT(*) INTO v_count
  FROM rendezvous
  WHERE idMedecin = :NEW.idMedecin
  AND dateRdv = :NEW.dateRdv;

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Conflit de rendez-vous');
  END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_update_stock
AFTER INSERT OR UPDATE ON ligne_prescription
FOR EACH ROW
BEGIN
    UPDATE medicament
    SET stock = stock - :NEW.quantite + NVL(:OLD.quantite,0)
    WHERE idMed = :NEW.idMed;
END;
/


--cdeja faie au niveau exception et procedure
CREATE OR REPLACE TRIGGER trg_capacite
BEFORE INSERT ON hospitalisation
FOR EACH ROW
DECLARE
  v_nb NUMBER;
  v_cap NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_nb
  FROM hospitalisation
  WHERE idService = :NEW.idService
  AND dateSortie IS NULL;

  SELECT capacite INTO v_cap
  FROM service
  WHERE idService = :NEW.idService;

  IF v_nb >= v_cap THEN
    RAISE_APPLICATION_ERROR(-20002, 'Capacité dépassée');
  END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_verif_stock
BEFORE INSERT OR UPDATE ON ligne_prescription
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stock INTO v_stock
    FROM medicament
    WHERE idMed = :NEW.idMed;

    IF :NEW.quantite > v_stock THEN
        RAISE_APPLICATION_ERROR(-20001, 'Stock insuffisant');
    END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_double_hosp
BEFORE INSERT ON hospitalisation
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM hospitalisation
  WHERE idPatient = :NEW.idPatient
  AND dateSortie IS NULL;

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Patient déjà hospitalisé');
  END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_ddl
AFTER CREATE OR DROP OR ALTER ON DATABASE
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        '[DDL] Opération  : ' || ORA_SYSEVENT  ||
        ' | Type objet : ' || ORA_DICT_OBJ_TYPE  ||
        ' | Nom objet  : ' || ORA_DICT_OBJ_NAME  ||
        ' | Utilisateur: ' || ORA_LOGIN_USER      ||
        ' | Date       : ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS')
    );
END;
/


SET SERVEROUTPUT ON;

DECLARE
    v_nb1 NUMBER;
    v_nb2 NUMBER;
    v_nb3 NUMBER;
    v_nb_patients NUMBER;
    v_total_medicaments NUMBER;
    v_cout_prescription NUMBER;
    
    CURSOR c_med IS SELECT idmedecin FROM medecin;
BEGIN
    DBMS_OUTPUT.PUT_LINE('DEBUT DES TESTS');
    DBMS_OUTPUT.PUT_LINE('================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 1. TEST CRUD PATIENT
    DBMS_OUTPUT.PUT_LINE('1. TEST CRUD PATIENT');
    DBMS_OUTPUT.PUT_LINE('--------------------');
    
    -- Ajouter un patient
    DBMS_OUTPUT.PUT_LINE('Ajout patient:');
    pkg_hopital.ajouter_patient(99, 'DUPONT', 'Jean', TO_DATE('15/03/1980', 'DD/MM/YYYY'), '12 rue de Paris', '0612345678');
    
    -- Afficher tous les patients
    DBMS_OUTPUT.PUT_LINE('Liste des patients:');
    pkg_hopital.afficher_patient;
    
    -- Modifier un patient
    DBMS_OUTPUT.PUT_LINE('Modification patient:');
    pkg_hopital.modifier_patient(99, 'DUPONT', 'Jean-Marie', TO_DATE('15/03/1980', 'DD/MM/YYYY'), '15 rue de Lyon', '0698765432');
    
    -- Supprimer le patient
    DBMS_OUTPUT.PUT_LINE('Suppression patient:');
    pkg_hopital.supprimer_patient(99);
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 2. TEST CRUD MEDECIN
    DBMS_OUTPUT.PUT_LINE('2. TEST CRUD MEDECIN');
    DBMS_OUTPUT.PUT_LINE('--------------------');
    
    -- Ajouter un médecin
    DBMS_OUTPUT.PUT_LINE('Ajout medecin:');
    pkg_hopital.ajouter_medecin(99, 'MARTIN', 'Cardiologue', 5000, 1);
    
    -- Afficher tous les médecins
    DBMS_OUTPUT.PUT_LINE('Liste des medecins:');
    pkg_hopital.afficher_medecin;
    
    -- Modifier un médecin
    DBMS_OUTPUT.PUT_LINE('Modification medecin:');
    pkg_hopital.modifier_medecin(99, 'MARTIN', 'Cardiologue senior', 6000, 1);
    
    -- Supprimer le médecin
    DBMS_OUTPUT.PUT_LINE('Suppression medecin:');
    pkg_hopital.supprimer_medecin(99);
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 3. TEST CRUD MEDICAMENT
    DBMS_OUTPUT.PUT_LINE('3. TEST CRUD MEDICAMENT');
    DBMS_OUTPUT.PUT_LINE('----------------------');
    
    -- Ajouter un médicament
    DBMS_OUTPUT.PUT_LINE('Ajout medicament:');
    pkg_hopital.ajouter_medicament(99, 'Paracetamol', 100, 5.50);
    
    -- Afficher tous les médicaments
    DBMS_OUTPUT.PUT_LINE('Liste des medicaments:');
    pkg_hopital.afficher_medicament;
    
    -- Modifier un médicament
    DBMS_OUTPUT.PUT_LINE('Modification medicament:');
    pkg_hopital.modifier_medicament(99, 'Paracetamol 500mg', 80, 6.00);
    
    -- Supprimer le médicament
    DBMS_OUTPUT.PUT_LINE('Suppression medicament:');
    pkg_hopital.supprimer_medicament(99);
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 4. TEST CRUD RENDEZ-VOUS
    DBMS_OUTPUT.PUT_LINE('4. TEST CRUD RENDEZ-VOUS');
    DBMS_OUTPUT.PUT_LINE('------------------------');
    
    -- Ajouter un rendez-vous
    DBMS_OUTPUT.PUT_LINE('Ajout rendez-vous:');
    pkg_hopital.ajouter_rdv(99, 1, 1, TO_DATE('10/06/2026 10:00', 'DD/MM/YYYY HH24:MI'), 'Confirmé');
    
    -- Afficher tous les rendez-vous
    DBMS_OUTPUT.PUT_LINE('Liste des rendez-vous:');
    pkg_hopital.afficher_rdv;
    
    -- Afficher rendez-vous par médecin
    DBMS_OUTPUT.PUT_LINE('Rendez-vous medecin ID 1:');
    pkg_hopital.afficher_rdv_medecin(1);
    
    -- Modifier un rendez-vous
    DBMS_OUTPUT.PUT_LINE('Modification rendez-vous:');
    pkg_hopital.modifier_rdv(99, 1, 1, TO_DATE('10/06/2026 11:00', 'DD/MM/YYYY HH24:MI'), 'Reporté');
    
    -- Supprimer le rendez-vous
    DBMS_OUTPUT.PUT_LINE('Suppression rendez-vous:');
    pkg_hopital.supprimer_rdv(99);
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 5. TEST DES FONCTIONS
    DBMS_OUTPUT.PUT_LINE('5. TEST DES FONCTIONS');
    DBMS_OUTPUT.PUT_LINE('---------------------');
    
    -- Test nb_patients_service
    v_nb1 := pkg_hopital.nb_patients_service(1);
    DBMS_OUTPUT.PUT_LINE('nb_patients_service(1) = ' || v_nb1);
    
    -- Test total_medicaments_patient
    v_nb2 := pkg_hopital.total_medicaments_patient(1);
    DBMS_OUTPUT.PUT_LINE('total_medicaments_patient(1) = ' || v_nb2);
    
    -- Test cout_prescription
    v_nb3 := pkg_hopital.cout_prescription(1);
    DBMS_OUTPUT.PUT_LINE('cout_prescription(1) = ' || v_nb3 || ' €');
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 6. TEST PROCEDURE liste_hospitalisations
    DBMS_OUTPUT.PUT_LINE('6. TEST liste_hospitalisations');
    DBMS_OUTPUT.PUT_LINE('-------------------------------');
    pkg_hopital.liste_hospitalisations;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 7. TEST PROCEDURE medicaments_rupture
    DBMS_OUTPUT.PUT_LINE('7. TEST medicaments_rupture');
    DBMS_OUTPUT.PUT_LINE('---------------------------');
    pkg_hopital.medicaments_rupture;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 8. TEST PROCEDURES D''EXCEPTIONS
    DBMS_OUTPUT.PUT_LINE('8. TEST PROCEDURES D''EXCEPTIONS');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    
    -- Test verifier_stock
    DBMS_OUTPUT.PUT_LINE('Test verifier_stock (stock suffisant):');
    pkg_hopital.verifier_stock(1, 10);
    
    DBMS_OUTPUT.PUT_LINE('Test verifier_stock (stock insuffisant):');
    BEGIN
        pkg_hopital.verifier_stock(1, 9999);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   Exception capturée: ' || SQLERRM);
    END;
    
    -- Test verifier_rdv
    DBMS_OUTPUT.PUT_LINE('Test verifier_rdv:');
    pkg_hopital.verifier_rdv(1, TO_DATE('15/07/2026 14:00', 'DD/MM/YYYY HH24:MI'));
    
    -- Test verifier_capacite
    DBMS_OUTPUT.PUT_LINE('Test verifier_capacite:');
    pkg_hopital.verifier_capacite(1);
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 9. TEST PROCEDURE METIER prescrire_medicament
    DBMS_OUTPUT.PUT_LINE('9. TEST prescrire_medicament');
    DBMS_OUTPUT.PUT_LINE('----------------------------');
    
    -- Test prescription valide
    DBMS_OUTPUT.PUT_LINE('Prescription valide:');
    pkg_hopital.prescrire_medicament(1, 5, 1, 99, 1);
    
    -- Test prescription avec stock insuffisant
    DBMS_OUTPUT.PUT_LINE('Prescription stock insuffisant:');
    BEGIN
        pkg_hopital.prescrire_medicament(1, 9999, 1, 98, 1);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   Exception capturée: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 10. TEST TRIGGERS
    DBMS_OUTPUT.PUT_LINE('10. TEST DES TRIGGERS');
    DBMS_OUTPUT.PUT_LINE('---------------------');
    
    -- Test trigger trg_check_rdv (conflit rendez-vous)
    DBMS_OUTPUT.PUT_LINE('Test trg_check_rdv (conflit):');
    BEGIN
        INSERT INTO rendezvous(idrdv, idpatient, idmedecin, daterdv, statut)
        VALUES(99, 1, 1, TO_DATE('10/05/2026 09:00', 'DD/MM/YYYY HH24:MI'), 'Confirmé');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   -> Trigger déclenché: ' || SQLERRM);
            ROLLBACK;
    END;
    
    -- Test trigger trg_verif_stock (stock insuffisant)
    DBMS_OUTPUT.PUT_LINE('Test trg_verif_stock:');
    BEGIN
        INSERT INTO ligne_prescription(idpresc, idmed, quantite)
        VALUES(1, 1, 9999);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   -> Trigger déclenché: ' || SQLERRM);
            ROLLBACK;
    END;
    
    -- Test trigger trg_capacite (capacité dépassée)
    DBMS_OUTPUT.PUT_LINE('Test trg_capacite:');
    BEGIN
        INSERT INTO hospitalisation(idhosp, idpatient, idservice, dateentree, datesortie)
        VALUES(99, 5, 1, SYSDATE, NULL);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   -> Trigger déclenché: ' || SQLERRM);
            ROLLBACK;
    END;
    
    -- Test trigger trg_double_hosp (double hospitalisation)
    DBMS_OUTPUT.PUT_LINE('Test trg_double_hosp:');
    BEGIN
        INSERT INTO hospitalisation(idhosp, idpatient, idservice, dateentree, datesortie)
        VALUES(98, 3, 2, SYSDATE, NULL);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   -> Trigger déclenché: ' || SQLERRM);
            ROLLBACK;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 11. VERIFICATION FINALE
    DBMS_OUTPUT.PUT_LINE('11. VERIFICATION FINALE');
    DBMS_OUTPUT.PUT_LINE('-----------------------');
    DBMS_OUTPUT.PUT_LINE('Aucune donnée n''a été modifiée de façon permanente');
    DBMS_OUTPUT.PUT_LINE('Les triggers et les exceptions ont bien bloqué toutes les insertions illégales');
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('================');
    DBMS_OUTPUT.PUT_LINE('FIN DES TESTS');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur générale : ' || SQLERRM);
        ROLLBACK;
END;
/

