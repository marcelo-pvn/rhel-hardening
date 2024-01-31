##
## Importante: Isso não é um script de auto-execução, e sim um passo-a-passo comentado.
##
## Criado por: Marcelo Pavan (marcelorp)
## Sistema operacional: Almalinux 9.x
##
## Descrição: Instalação do MongoDB
##

# Instalação do repositório oficial
echo '[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc' >> /etc/yum.repo.d/mongodb.repo

# Limpeza do cache
sudo yum clean all

# Instalação do MongoDB
sudo yum install -y mongodb-org

# Inicialização do MongoDB
sudo systemctl start mongod

# Auto-inicialização do MongoDB ao inicial o sistema operacional
sudo systemctl enable mongod

# Conexão com o banco de dados (ainda sem usuário definido)
mongosh --port 27017

# Criação de super-usuário
use admin
db.createUser(
    {
        user: "myUserAdmin",
        pwd: passwordPrompt(), // or cleartext password
        roles: [ 
            { role: "userAdminAnyDatabase", db: "admin" },
            { role: "readWriteAnyDatabase", db: "admin" } 
        ]
    }
)

# Fim