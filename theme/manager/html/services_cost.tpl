{$meta_title = 'Стоимость услуг' scope=parent}

{capture name='page_styles'}
    <link href="theme/manager/assets/plugins/Magnific-Popup-master/dist/magnific-popup.css" rel="stylesheet"/>
    <link rel="stylesheet" type="text/css"
          href="theme/manager/assets/plugins/datatables.net-bs4/css/dataTables.bootstrap4.css">
    <link href="https://cdn.jsdelivr.net/npm/suggestions-jquery@21.12.0/dist/css/suggestions.min.css" rel="stylesheet"/>
    <link href="theme/manager/assets/plugins/bootstrap-datepicker/bootstrap-datepicker.min.css" rel="stylesheet"
          type="text/css"/>
    <link href="theme/manager/assets/plugins/daterangepicker/daterangepicker.css" rel="stylesheet">
{/capture}

{capture name='page_scripts'}
    <script src="theme/manager/assets/plugins/moment/moment.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.17.1/moment-with-locales.min.js"></script>
    <script src="theme/manager/assets/plugins/daterangepicker/daterangepicker.js"></script>
    <script src="theme/manager/assets/plugins/Magnific-Popup-master/dist/jquery.magnific-popup.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/suggestions-jquery@21.12.0/dist/js/jquery.suggestions.min.js"></script>
    <script>
        $(function () {

            $('.add-services_cost-modal, .edit-services_cost-modal').on('click', function () {
                $('#add_services_cost_form')[0].reset();

                if ($(this).hasClass('edit-services_cost-modal')) {
                    let id = $(this).attr('data-id');

                    $.ajax({
                        method: 'POST',
                        dataType: 'JSON',
                        data: {
                            id: id,
                            action: 'get_services_cost'
                        },
                        success: function (services_cost) {
                            $('#region').val(services_cost['region']);
                            $('#reject_reason_cost').val(services_cost['reject_reason_cost']);
                            $('#insurance_cost').val(services_cost['insurance_cost']);
                            $('input[name="action"]').val('edit');
                            $('input[name="id"]').val(id);
                        }
                    })
                }else{
                    $('input[name="action"]').val('add');
                }


                $('#add-services_cost-modal').modal();
            });

            $('.formSubmit').on('click', function () {
                let form = $('#add_services_cost_form').serialize();

                $.ajax({
                    method: 'POST',
                    data: form,
                    success: function () {
                        location.reload();
                    }
                })
            });

            $('.delete').on('click', function () {

                let that = $(this);
                let code_id = that.attr('data-code');

                $.ajax({
                    method: 'POST',
                    data: {
                        action: 'delete',
                        code_id: code_id
                    },
                    success: function () {
                        that.closest('tr').remove();
                    }
                })
            });
        });
    </script>
{/capture}

<div class="page-wrapper">
    <!-- ============================================================== -->
    <!-- Container fluid  -->
    <!-- ============================================================== -->
    <div class="container-fluid">
        <!-- ============================================================== -->
        <!-- Bread crumb and right sidebar toggle -->
        <!-- ============================================================== -->
        <div class="row page-titles">
            <div class="col-md-6 col-8 align-self-center">
                <h3 class="text-themecolor mb-0 mt-0">Стоимость услуг</h3>
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="/">Главная</a></li>
                    <li class="breadcrumb-item"><a href="/">Справочники</a></li>
                    <li class="breadcrumb-item active"><a href="/services_cost">Стоимость услуг</a></li>
                </ol>
            </div>
            <div class="col-md-6 col-4 align-self-center">
                <button class="btn float-right hidden-sm-down btn-success add-services_cost-modal">
                    Добавить
                </button>
            </div>
        </div>

        <div class="row">
            <div class="col-12">

                <div class="card">
                    <div class="card-body">
                        <h4 class="card-title"></h4>
                        <h6 class="card-subtitle"></h6>
                        <div class="table-responsive m-t-40">
                            <div class="dataTables_wrapper container-fluid dt-bootstrap4 no-footer">
                                <table id="config-table" class="table display table-striped dataTable"
                                       style="font-size: 14px">
                                    <thead>
                                    <tr>
                                        <th style="width: 90px">
                                            ID
                                        </th>
                                        <th style="width: 90px">
                                            Регион
                                        </th>
                                        <th style="width: 90px">
                                            Стоимость причины отказа
                                        </th>
                                        <th style="width: 90px">
                                            Стоимость страховки при выдаче
                                        </th>
                                    </tr>
                                    {*}
                                    <tr>
                                        <th style="width: 90px" class="jsgrid-header-cell">
                                            <input type="text" class="form-control searchable"></th>
                                        <th style="width: 250px" class="jsgrid-header-cell"><input type="text"
                                                                                                   class="form-control searchable">
                                        </th>
                                        
                                    </tr>
                                    {*}
                                    </thead>
                                    <tbody>
                                    {if !empty($services_cost)}
                                        {foreach $services_cost as $cost}
                                            <tr>
                                                <td class="jsgrid-header-cell" style="width: 10%">{$cost->id}</td>
                                                <td class="jsgrid-header-cell" style="width: 30%">{$cost->region}</td>
                                                <td class="jsgrid-header-cell" style="width: 25%">{$cost->reject_reason_cost}</td>
                                                <td class="jsgrid-header-cell" style="width: 25%">{$cost->insurance_cost}</td>
                                                <td class="jsgrid-header-cell" style="width: 10%">
                                                    <div data-id="{$cost->id}"
                                                         class="btn btn-outline-warning edit-services_cost-modal"><i
                                                                class=" fas fa-edit"></i>
                                                    </div>
                                                </td>
                                            </tr>
                                        {/foreach}
                                    {/if}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>

    </div>

    {include file='footer.tpl'}

</div>

<div id="add-services_cost-modal" class="modal fade bd-example-modal-sm" tabindex="-1" role="dialog"
     aria-labelledby="mySmallModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-md">
        <div class="modal-content">

            <div class="modal-header">
                <h4 class="modal-title">Добавить стоимость услуг</h4>
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            </div>
            <div class="modal-body">
                <div class="alert" style="display:none"></div>
                <form method="POST" id="add_services_cost_form">
                    <input type="hidden" name="action">
                    <input type="hidden" name="id">
                    <div class="form-group">
                        <label for="region" class="control-label">Регион</label>
                        <input type="text" class="form-control" name="region" id="region" value=""/>
                    </div>
                    <div class="form-group">
                        <label for="reject_reason_cost" class="control-label">Стоимость причины отказа</label>
                        <input type="text" class="form-control" name="reject_reason_cost" id="reject_reason_cost" value=""/>
                    </div>
                    <div class="form-group">
                        <label for="insurance_cost" class="control-label">Стоимость страховки при выдаче</label>
                        <input type="text" class="form-control" name="insurance_cost" id="insurance_cost" value=""/>
                    </div>
                    <div>
                        <input type="button" class="btn btn-danger" data-dismiss="modal" value="Отмена">
                        <input type="button" class="btn btn-success formSubmit" value="Сохранить">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>