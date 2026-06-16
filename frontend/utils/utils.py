from PyQt5 import QtCore

def decode_status(status):
    if (status == 0):
        return "未受理"
    elif (status == 1):
        return "已受理"
    else:
        return "已修复"

def decode_date(date):
    return date.toString(QtCore.Qt.ISODate)

def encode_date(year, month, day):
    date = QtCore.QDate(int(year), int(month), int(day))
    return date.toString(QtCore.Qt.ISODate)

def concat_address(flatid, roomid):
    return flatid + "公寓" + roomid + "号房"