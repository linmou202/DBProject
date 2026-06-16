from PyQt5 import QtWidgets, QtSql, QtCore
import sys
from ui.Ui_login import Ui_login_interface

if __name__ == '__main__':

    # establish db connection
    con = QtSql.QSqlDatabase.addDatabase('QMYSQL')
    con.setHostName('localhost')
    con.setDatabaseName('flat')
    con.setUserName('root')
    con.setPassword('123')
    con.open()

    app = QtWidgets.QApplication([])

    login_interface = QtWidgets.QMainWindow()
    login_interface.setAttribute(QtCore.Qt.WA_DeleteOnClose, True)
    login_interface.ui = Ui_login_interface()
    login_interface.ui.setupUi(login_interface)
    login_interface.show()

    sys.exit(app.exec_())