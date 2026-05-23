trailing PopupMenuButtonString(
  onSelected (value) {
    if (value == 'edit') {
       Trigger your Edit navigation
    } else if (value == 'delete') {
      _showDeleteConfirmation(context, ref, sale.id);
    } else if (value == 'print') {
      BillService.generateSingleBill(sale);
    }
  },
  itemBuilder (context) = [
    const PopupMenuItem(value 'print', child Row(children [Icon(Icons.print), Text( Generate Bill)])),
    const PopupMenuItem(value 'edit', child Row(children [Icon(Icons.edit), Text( Edit)])),
    const PopupMenuItem(value 'delete', child Row(children [Icon(Icons.delete, color Colors.red), Text( Delete)])),
  ],
),