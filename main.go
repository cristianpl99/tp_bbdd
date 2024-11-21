package main

import (
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
	_ "github.com/lib/pq"
	"go.etcd.io/bbolt"
)

// no usar varibles globales
// var opcion int = 9

type cliente struct {
	id_cliente         int
	nombre             string
	apellido           string
	dni                	int
	fecha_de_nacimiento string
	telefono           	string
	email             	string
}

type operadore struct {
	id_operadore int
	nombre       string
	apellido     string
	dni          int
	fecha_ingreso string
	disponible   bool
}

type tramite struct {
	id_tramite       int
	id_cliente       int
	id_cola_atencion int
	tipo_tramite     string
	f_inicio_gestion string
	descripcion      string
	f_fin_gestion    string
	respuesta        string
	estado           string
}

type cola_atencion struct {
	id_cola_atencion   int
	id_cliente         int
	f_inicio_llamado   string
	id_operadore       int
	f_inicio_atencion  string
	estado             string
}

type Error struct {
	id_error              int
	operacion             string
	id_cliente            int
	id_cola_atencion      int
	tipo_tramite          string
	id_tramite            int
	estado_cierre_tramite string
	f_error               string
	motivo                string
}

type llamado struct {
	id_llamado		   	int
	tipo_llamado		string
    id_cliente			int
    fecha_llamado		string
	estado  			string
	descripcion         string
	motivo				string
}

func mostrarMenu() {
	menu := `
****************-MENU-**********************
 1 - Crear base de datos      
 2 - Crear tablas
 3 - Agregar PKs y FKs
 4 - Eliminar PKs y FKs
 5 - Cargar datos   
 6 - Crear Stored Producedures y triggers 
 7 - Iniciar pruebas          
 8 - Cargar datos en BoltDB   
 0 - Salir                  
********************************************`
	fmt.Println(menu)
}

func main() {
	conex := "user=postgres host=localhost dbname=chamizo_pereyra_prieto_sacks_db1 sslmode=disable"
	db, err := sql.Open("postgres", conex)
	if err != nil {
		log.Fatal("Error al conectar la base de datos:", err)
	}
	defer db.Close()
	
	mostrarMenu()
	var (
	opcion int
	// control de flujo
	baseCreada		 bool = false
	tablasCreadas    bool = false
	pksCreadas       bool = false
	datosInsertados  bool = false
	funcionesCreadas bool = false
	)
	for {
		fmt.Print("Ingrese el número de opción a realizar: ")
		fmt.Scanf("%d", &opcion)
		fmt.Print("Operación solicitada: ", opcion)
		fmt.Print("\n")
		if opcion < 0 || opcion >= 9 {
			fmt.Print("Ingrese una opción válida. \n")
			os.Exit(0)
		}
	

		switch opcion {
		case 1:
			fmt.Print("Creando Base de datos... \n")
			createDatabase()
			baseCreada = true
			fmt.Print("Base de datos creada exitosamente. \n")
		case 2:
			fmt.Print("Creando Tablas... \n")
			if baseCreada {
				createTables(db)
				tablasCreadas = true
				fmt.Print("Tablas de base de datos creadas exitosamente. \n")
			}else{
				desincronizacion()
			}	
		case 3:
			fmt.Print("Creando PK's y FK's... \n")
			if baseCreada && tablasCreadas {
				createPksAndFks(db)
				pksCreadas = true
				fmt.Print("PK's y FK's de tablas creadas exitosamente. \n")
			}else{
				desincronizacion()
			}	
		case 4:
			fmt.Print("Borrando PK's y FK's... \n")
			if baseCreada && tablasCreadas {
				dropPksAndFks(db)
				pksCreadas = false
			fmt.Print("PK's y FK's eliminadas creadas exitosamente. \n")
			}else{
				desincronizacion()
			}	
		case 5:
			fmt.Print("Insertando datos en tablas... \n")
			if baseCreada && tablasCreadas && pksCreadas{
			insertValues(db)
			datosInsertados = true
			fmt.Print("Datos insertados en las tablas exitosamente. \n")
			}else{
				desincronizacion()
			}
		case 6:
			fmt.Print("Creando y cargando funciones... \n")
			if baseCreada && tablasCreadas && pksCreadas && datosInsertados{
			cargaFunciones(db)
			funcionesCreadas = true
			fmt.Print("Funciones Creadas exitosamente. \n")
			}else{
				desincronizacion()
			}
		case 7:
			fmt.Print("Iniciando pruebas... \n")
			if baseCreada && tablasCreadas && pksCreadas && datosInsertados && funcionesCreadas{
			iniciarPruebas(db)
			fmt.Print("Pruebas concluidas exitosamente. \n")
			}else{
				desincronizacion()
			}
		case 8:
			fmt.Print("Cargando datos en BoltDB... \n")
	  		mostrarMenuNoSQL()
//			fmt.Print("Datos cargados! \n")
		case 0:
			os.Exit(0)
		}
	}
}

func createDatabase() {
	//Conecto a otra bbdd para poder hacer el drop si ya existe la bbdd
	temp := "user=postgres host=localhost dbname=postgres sslmode=disable"
	db, err := sql.Open("postgres", temp)
	if err != nil {
		log.Fatalf("Error al conectar a la base de datos temporal: %v", err)
	}
	defer db.Close()
	
	_, err = db.Exec("drop database if exists chamizo_pereyra_prieto_sacks_db1")
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec("create database chamizo_pereyra_prieto_sacks_db1")
	if err != nil {
		log.Fatal(err)
	}
}

func createTables(db *sql.DB) {
	contenido, err := ioutil.ReadFile("sql/tablas.sql")
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec(string(contenido))
	if err != nil {
		log.Fatal(err)
	}
}

func createPksAndFks(db *sql.DB) {
	contenido, err := ioutil.ReadFile("sql/add-pks-fks.sql")
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec(string(contenido))
	if err != nil {
		log.Fatal(err)
	}
}

func dropPksAndFks(db *sql.DB) {
	contenido, err := ioutil.ReadFile("sql/delete-pks-fks.sql")
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec(string(contenido))
	if err != nil {
		log.Fatal(err)
	}
}

func insertValues(db *sql.DB) {
	contenido, err := ioutil.ReadFile("sql/datos_volcados.sql")
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec(string(contenido))
	if err != nil {
		log.Fatal(err)
	}
}

// testear y agregar al git //
func cargaFunciones(db *sql.DB) {
	funciones := []string{
		"sql/alta-tramite.sql",
		"sql/atencion-de-llamado-en-espera.sql",
		"sql/desistimiento-de-llamado.sql",
		"sql/finalizacion-de-llamado.sql",
		"sql/ingreso-llamado.sql",
		"sql/cierre-tramite.sql",
		"sql/reporte-rendimiento.sql",
		"sql/trigger-reporte-rendimiento.sql",
		"sql/email-nuevo-tramite.sql",
		"sql/trigger-nuevo-tramite.sql",
		"sql/email-cierre-tramite.sql",
		"sql/trigger-cierre-tramite.sql",
	}

	for _, funcion := range funciones {
		contenido, err := ioutil.ReadFile(funcion)
		if err != nil {
			log.Fatalf("Error al leer el archivo %s: %v", funcion, err)
		}

		_, err = db.Exec(string(contenido))
		if err != nil {
			log.Fatalf("Error al ejecutar el archivo %s: %v", funcion, err)
		}
		fmt.Printf("Funcion %s cargado exitosamente.\n", funcion)
	}	
}

func iniciarPruebas(db *sql.DB) {
	contenido, err := ioutil.ReadFile("sql/datos_prueba.sql")
		if err != nil {
			log.Fatal(err)
		}
	
		_, err = db.Exec(string(contenido))
		if err != nil {
			log.Fatal(err)
		}
			datos, err := db.Query("select * from datos_de_prueba;")
	if err != nil {
		log.Fatal(err)
	}
	defer datos.Close()
		for i := 0; datos.Next(); i++ {
    	var (
	        id_orden              sql.NullInt32
	        operacion             sql.NullString
	        id_cliente            sql.NullInt32
	        id_cola_atencion      sql.NullInt32
	        tipo_tramite          sql.NullString
	        descripcion_tramite   sql.NullString
	        id_tramite            sql.NullInt32
	        estado_cierre_tramite sql.NullString
	        respuesta_tramite     sql.NullString
	    )    
        if err := datos.Scan(
            &id_orden,
            &operacion,
            &id_cliente,
            &id_cola_atencion,
            &tipo_tramite,
            &descripcion_tramite,
            &id_tramite,
            &estado_cierre_tramite,
            &respuesta_tramite,
        ); err != nil {
            log.Fatal(err)
        }

		if operacion.Valid {
		    operacion_sin_espacios := strings.TrimSpace(operacion.String)
	    	switch operacion_sin_espacios {
			    case "nuevo llamado":
			        fmt.Print("Ingresando nuevo llamado... \n")
			        _, err = db.Exec("select ingreso_llamado($1)", id_cliente)
					if err != nil {
						log.Fatal("Error al ingresar el llamado: %v", err)
					}
			
			    case "atencion llamado":
			        fmt.Print("Atendiendo nuevo llamado... \n")
			        _, err = db.Exec("select atender_llamado_en_espera()")
					if err != nil {
						log.Fatal("Error al atender el llamado: %v", err)
					}
			
			    case "baja llamado":
			        fmt.Print("Dando de baja llamado... \n")
			        _, err = db.Exec("select desistimiento_de_llamado($1)", id_cola_atencion)
   					if err != nil {
   						log.Fatal("Error al dar de baja el llamado: %v", err)
   					}
			
			    case "fin llamado":
			        fmt.Print("Finalizando llamado... \n")
			        _, err = db.Exec("select finalizar_llamado($1)", id_cola_atencion)
   					if err != nil {
   						log.Fatal("Error al finalizar el llamado: %v", err)
   					}
			
			    case "alta tramite":
			        fmt.Print("Dando de alta un tramite... \n")
			        _, err = db.Exec("select alta_tramite($1, $2, $3)", id_cola_atencion, tipo_tramite, descripcion_tramite)
   					if err != nil {
   						log.Fatal("Error al dar de alta un tramite: %v", err)
   					}
			        
			    case "cierre tramite":
			        fmt.Print("Dando cierre a un tramite... \n")
			        _, err = db.Exec("select cierre_tramite($1, $2, $3)", id_tramite, estado_cierre_tramite, respuesta_tramite)
   					if err != nil {
   						log.Fatal("Error al cerrar un tramite: %v", err)
   					}
			
			    default:
			        fmt.Print("Operación desconocida \n")
			        
			    }
			} else {
			    fmt.Print("Operación es NULL \n")
			}
		}
	}
	
func desincronizacion(){ 
		fmt.Print("Desincronizacion en el orden de las opciones\n") 
	}

func mostrarMenuNoSQL() {
    menuNoSQL := `
********/MENU NoSQL\***********
1 -> Crear base de datos
2 -> Crear tablas
3 -> Cargar datos 
4 -> Volver al menu principal
*******************************`
    fmt.Println(menuNoSQL)

    var opcionNoSQL int
    var db *bbolt.DB 
    for {
        fmt.Print("Ingrese el número de opción a realizar: ")
        fmt.Scanf("%d", &opcionNoSQL)
        fmt.Print("Operación solicitada: ", opcionNoSQL)
        fmt.Print("\n")
        if opcionNoSQL < 0 || opcionNoSQL >= 5 {
            fmt.Print("Ingrese una opción válida. \n")
            os.Exit(0)
        }

        switch opcionNoSQL {
        case 1:
            fmt.Print("Creando Base de datos... \n")
            var err error
            db, err = crearConexionDBNoSQL()
            if err != nil {
                fmt.Println("Error al crear la base de datos:", err)
                continue
            }
            fmt.Print("Base de datos creada exitosamente. \n")

        case 2:
            fmt.Print("Creando Tablas... \n")
            if db == nil {
                fmt.Println("Error: No se ha creado la base de datos aún.")
                continue
            }
            err := crearTablasNoSQL(db)
            if err != nil {
                fmt.Println("Error al crear las tablas:", err)
                continue
            }
            fmt.Print("Tablas de base de datos creadas exitosamente. \n")

        case 3:
            fmt.Print("Cargando datos... \n")
            if db == nil {
                fmt.Println("Error: No se ha creado la base de datos aún.")
                continue
            }
            cargarDatosEnBoltDB(db)
            fmt.Print("Datos cargados exitosamente. \n")

        case 4:
            fmt.Print("Volviendo al menu principal... \n")
            mostrarMenu()
            return
        }
    }
}

func crearConexionDBNoSQL() (*bbolt.DB, error) {
    // Verificar si existe el archivo
    if _, err := os.Stat("chamizo_pereyra_prieto_sacks_db1"); err == nil {
        // Si el archivo existe, se podría eliminar si es necesario
        if err := os.Remove("chamizo_pereyra_prieto_sacks_db1"); err != nil {
            log.Fatal("Error al eliminar el archivo de la base de datos existente:", err)
            return nil, err
        }
    }

    // Crear la base de datos
    db, err := bbolt.Open("chamizo_pereyra_prieto_sacks_db1", 0600, nil)
    if err != nil {
        log.Fatal("Error al abrir la base de datos:", err)
        return nil, err
    }
    return db, nil
}

func crearTablasNoSQL(db *bbolt.DB) error {
    err := db.Update(func(tx *bbolt.Tx) error {
        // Crear o abrir buckets según sea necesario
        _, err := tx.CreateBucketIfNotExists([]byte("clientes"))
        if err != nil {
            return err
        }
        _, err = tx.CreateBucketIfNotExists([]byte("operadores"))
        if err != nil {
            return err
        }
        _, err = tx.CreateBucketIfNotExists([]byte("tramites"))
        if err != nil {
            return err
        }
        _, err = tx.CreateBucketIfNotExists([]byte("llamados"))
        if err != nil {
            return err
        }
        return nil
    })
    return err
}

func cargarDatosEnBoltDB(db *bbolt.DB) {

    // Datos de tres clientes
    clientes := []cliente{
        {1, "christian", "chamizo", 41139611, "1998-24-04", "123-456-7890", "Christian01@gmail.com"},
        {2, "juan", "perez", 87654321, "1985-03-22", "234-567-8901", "jperez@gmail.com"},
        {3, "ana", "gomez", 11223344, "1990-05-10", "345-678-9012", "anagomez18@gmail.com"},
    }
    // Datos de operadores
	operadores := []operadore{
		{1, "Wilhelm", "Steinitz", 5053058, "2018-05-14 00:00:00", true},
		{2, "Emanuel", "Lasker", 24610127, "2018-12-24 00:00:00", true},
		{3, "Jose Raul", "Capablanca", 9068298, "2019-11-19 00:00:00", true},
	}

	//Datos de llamados
	llamados := []llamado{
		{1, "nuevo llamado", 21,"2014-12-11", "En espera", "llamando","?id de cliente no valido"},
		{2, "nuevo llamado", 11,"2014-08-11", "En espera", "conectando","?id de cliente no encontrado"},
		{8, "baja llamado", 2, "2008-07-12","Llamando", "En espera", "act fila 2 estado desistido"},
	}

	//Datos de tramites
	tramites := []tramite{
		{2, 11, 4, "alta tramite","2009-12-01", "consulta", "2009-12-05","tramite iniciado","aceptado"},
		{3, 9 , 3, "baja tramite","2007-11-05", "reclamo", "2009-12-05","tramite en proceso","denegado"},
		{5, 19, 13, "alta tramite","2012-06-08", "consulta", "2020-11-09","tramite iniciado","aceptado"},
	}
  
    insertarClientes(db,clientes)
    insertarOperadores(db,operadores)
    insertarLlamados(db,llamados)
    insertarTramites(db,tramites)
}

func insertarClientes(db *bbolt.DB, clientes []cliente) error {
    return db.Update(func(tx *bbolt.Tx) error {
        // Crear o acceder al bucket "Clientes"
        b, err := tx.CreateBucketIfNotExists([]byte("Clientes"))
        if err != nil {
            return fmt.Errorf("error al crear o acceder a la tabla Clientes: %v", err)
        }
        // Recorrer la lista de clientes
        for _, cliente := range clientes {
            // Serializar los datos del cliente
            valor := fmt.Sprintf("%d|%s|%s|%d|%s|%s|%s",
                cliente.id_cliente,
                cliente.nombre,
                cliente.apellido,
                cliente.dni,
                cliente.fecha_de_nacimiento,
                cliente.telefono,
                cliente.email,
            )
            	fmt.Printf("id_cliente: %d, nombre: %s apellido: %s, dni: %d, fecha_de_nacimiento: %s, telefono:%s,email:%s\n",
  				cliente.id_cliente, cliente.nombre, cliente.apellido, cliente.dni, cliente.fecha_de_nacimiento, cliente.telefono, cliente.email)

            // Convertir el ID del cliente en clave
            clave := []byte(fmt.Sprintf("%d", cliente.id_cliente))

            // Insertar el cliente en la tabla
            if err := b.Put(clave, []byte(valor)); err != nil {
                return fmt.Errorf("error al insertar el cliente con ID %d: %w", cliente.id_cliente, err)    		
            }
         
        }
        return nil
    })
}

func insertarOperadores(db *bbolt.DB, operadores []operadore) error {
    return db.Update(func(tx *bbolt.Tx) error {
        // Crear o acceder al bucket "Operadores"
        b, err := tx.CreateBucketIfNotExists([]byte("Operadores"))
        if err != nil {
            return fmt.Errorf("error al crear o acceder a la tabla Operadores: %v", err)
        }
        // Recorrer la lista de operadores
        for _, operador := range operadores {
            // Serializar los datos del operador
            valor := fmt.Sprintf("%d|%s|%s|%d|%s|%t",
                operador.id_operadore,
                operador.nombre,
                operador.apellido,
                operador.dni,
                operador.fecha_ingreso,
                operador.disponible,
            )
            fmt.Printf("id_operadore: %d, nombre: %s, apellido: %s, dni: %d, fecha_ingreso: %s, disponible: %t\n",
                operador.id_operadore, operador.nombre, operador.apellido, operador.dni, operador.fecha_ingreso, operador.disponible)

            // Convertir el ID del operador en clave
            clave := []byte(fmt.Sprintf("%d", operador.id_operadore))

            // Insertar el operador en la tabla
            if err := b.Put(clave, []byte(valor)); err != nil {
                return fmt.Errorf("error al insertar el operador con ID %d: %w", operador.id_operadore, err)
            }
        }
        return nil
    })
}

func insertarLlamados(db *bbolt.DB, llamados []llamado) error {
    return db.Update(func(tx *bbolt.Tx) error {
        // Crear o acceder al bucket "Llamados"
        b, err := tx.CreateBucketIfNotExists([]byte("Llamados"))
        if err != nil {
            return fmt.Errorf("error al crear o acceder a la tabla Llamados: %v", err)
        }
        // Recorrer la lista de llamados
        for _, llamado := range llamados {
            // Serializar los datos del llamado
            valor := fmt.Sprintf("%d|%s|%d|%s|%s|%s|%s",
                llamado.id_llamado,
                llamado.tipo_llamado,
                llamado.id_cliente,
                llamado.fecha_llamado,
                llamado.estado,
                llamado.descripcion,
                llamado.motivo,
            )
            fmt.Printf("id_llamado: %d, tipo_llamado: %s, id_cliente: %d, fecha_llamado: %s, estado: %s, descripcion: %s, motivo: %s\n",
                llamado.id_llamado, llamado.tipo_llamado, llamado.id_cliente, llamado.fecha_llamado, llamado.estado, llamado.descripcion, llamado.motivo)

            // Convertir el ID del llamado en clave
            clave := []byte(fmt.Sprintf("%d", llamado.id_llamado))

            // Insertar el llamado en la tabla
            if err := b.Put(clave, []byte(valor)); err != nil {
                return fmt.Errorf("error al insertar el llamado con ID %d: %w", llamado.id_llamado, err)
            }
        }
        return nil
    })
}

func insertarTramites(db *bbolt.DB, tramites []tramite) error {
    return db.Update(func(tx *bbolt.Tx) error {
        // Crear o acceder al bucket "Tramites"
        b, err := tx.CreateBucketIfNotExists([]byte("Tramites"))
        if err != nil {
            return fmt.Errorf("error al crear o acceder a la tabla Tramites: %v", err)
        }
        // Recorrer la lista de trámites
        for _, tramite := range tramites {
            // Serializar los datos del trámite
            valor := fmt.Sprintf("%d|%s|%s|%d|%s|%s|%s",
                tramite.id_tramite,
                tramite.tipo_tramite,
                tramite.descripcion,
                tramite.id_cliente,
                tramite.f_inicio_gestion,
                tramite.f_fin_gestion,
                tramite.respuesta,
            )
            fmt.Printf("id_tramite: %d, tipo_tramite: %s, descripcion: %s, id_cliente: %d, f_inicio_gestion: %s, f_fin_gestion: %s, respuesta: %s\n",
                tramite.id_tramite, tramite.tipo_tramite, tramite.descripcion, tramite.id_cliente, tramite.f_inicio_gestion, tramite.f_fin_gestion, tramite.respuesta)

            // Convertir el ID del trámite en clave
            clave := []byte(fmt.Sprintf("%d", tramite.id_tramite))

            // Insertar el trámite en la tabla
            if err := b.Put(clave, []byte(valor)); err != nil {
                return fmt.Errorf("error al insertar el trámite con ID %d: %w", tramite.id_tramite, err)
            }
        }
        return nil
    })
}




