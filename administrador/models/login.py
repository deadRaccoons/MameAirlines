# -*- coding: utf-8 -*-
from Conexion import *

__all__= ['Login']

class Login(object):

    def __init__(self, correo, secreto):
        self.correo = correo
        self.secreto = secreto
        self.c = Conexion()
    
    def crea(self):
        if(self.c.consultar("select correo from logins where correo = '"+ self.correo +"';") is not None):
            return 2
        else:
            return self.c.actualizar("insert into logins values ('"+ self.correo + "', '"+ self.secreto +"', 'y');")

    def borra(self):
        return self.c.actualizar("delete from logins where correo = '"+ self.correo +"';")

nuevo = Login("kuber@hotmail.com","mame")
print nuevo.crea()