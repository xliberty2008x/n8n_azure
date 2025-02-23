# Copy this file as terraform.tfvars and update the values below with your own credentials and settings.

# Azure credentials configuration
subscription_id = "<YOUR_AZURE_SUBSCRIPTION_ID_HERE>"      
client_id       = "<YOUR_AZURE_CLIENT_ID_HERE>"           
client_secret   = "<YOUR_AZURE_CLIENT_SECRET_HERE>"        
tenant_id       = "<YOUR_AZURE_TENANT_ID_HERE>"            

# PostgreSQL configuration
administrator_login         = "<YOUR_POSTGRES_ADMIN_LOGIN_HERE>"      
administrator_login_password = "<YOUR_POSTGRES_ADMIN_PASSWORD_HERE>"   
postgres_username           = "<YOUR_POSTGRES_USERNAME_HERE>"           
postgres_password           = "<YOUR_POSTGRES_PASSWORD_HERE>"           

# n8n deployment configuration
n8n_deployment_and_service_name = "<YOUR_N8N_DEPLOYMENT_AND_SERVICE_NAME_HERE>"  
namespace                       = "<YOUR_KUBERNETES_NAMESPACE_HERE>"           
claim0_persistent_volume_name   = "<YOUR_PERSISTENT_VOLUME_CLAIM_NAME_HERE>"     
postgres_port                   = 5432                                          
postgres_database               = "<YOUR_POSTGRES_DATABASE_NAME_HERE>"          
n8n_protocol                    = "<YOUR_N8N_PROTOCOL_HERE>"                    
n8n_port                        = 5678                                          
PGHOST                          = "<YOUR_POSTGRES_HOSTNAME_HERE>"                
service_spec_type               = "<YOUR_SERVICE_SPEC_TYPE_HERE>"                

