from Conexion import *

class Administrador(object):

    def __init__(self, correo, nombres, apellidos):
        self.correo = correo
        self.nombres = nombres
        self.apellidos = apellidos
        self.c = Conexion()

    def crea(self):
        return self.c.actualizar("insert into administrador values('"+ self.correo +"', '"+ self.nombres +"', '"+ self.apellidos +"')")

    def borra(self):
        return self.c.actualizar("delete from logins where correo = '"+ self.correo +"';")

    def actualiza(self, correo, secreto, activo):
        c.actualizar("update administrador set nombres = '"+ self.nombres +"', apellidos = '"+ self.apellidos +"' where correo = '"+ self.correo +"';")
        
    @staticmethod
    def getAdministrador(correo):
        if correo is None:
            return None
        else:
            c = Conexion()
            a = c.consultar("select * from administrador where correo = '"+ correo +"';")
            if a is not None:
                return Administrador(a[0][0], a[0][1], a[0][2])
            return a

    @staticmethod
    def all_():
        c = Conexion()
        todos = []
        for resultado in c.consultar("select * from administrador"):
            r = list(resultado)
            todos.append(Administrador(r[0], r[1], r[2]))
        return todos
