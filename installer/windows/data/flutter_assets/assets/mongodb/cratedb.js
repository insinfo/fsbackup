//execute comando
//  mongo -u sisadmin -p s1sadm1n admin  .\cratedb.js
//.\mongo.exe --port 27085  admin  .\cratedb.js
//db = connect("sisadmin:s1sadm1n@localhost:27020/admin");

db = db.getSiblingDB('fsbackup');//cria banco de dados
//cria usuario de banco
db.createUser({
    user: "sisadmin",
    pwd: "s1sadm1n",
    roles: [
        {
            role: "dbAdmin",
            db: "fsbackup"
        },
        {
            role: "dbOwner",
            db: "fsbackup"
        },
        {
            role: "enableSharding",
            db: "fsbackup"
        },
        {
            role: "read",
            db: "fsbackup"
        },
        {
            role: "readWrite",
            db: "fsbackup"
        },
        {
            role: "userAdmin",
            db: "fsbackup"
        }
    ],
    authenticationRestrictions: []
})
//cria usuario do sistema
db.user.insert({
    "id": "c438b248-1e1e-46d2-807f-79b2fe788d19",
    "cpf": "11111111111",
    "nome": "admin",
    "username": "admin",
    "password": "410C6/igS7r1j5e1A7UYlA==@cript",//@dm1n#$%
    "ativo": true,
    "dataCadastro": "2021-01-06 13:38:51.924",
});
