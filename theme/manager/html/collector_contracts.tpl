{$meta_title='Мои договоры' scope=parent}

{capture name='page_scripts'}
    <script src="theme/{$settings->theme|escape}/assets/plugins/Magnific-Popup-master/dist/jquery.magnific-popup.min.js"></script>
    <script src="theme/manager/assets/plugins/moment/moment.js"></script>
    <script src="theme/manager/assets/plugins/bootstrap-datepicker/bootstrap-datepicker.min.js"></script>
    <!-- Date range Plugin JavaScript -->
    <script src="theme/manager/assets/plugins/timepicker/bootstrap-timepicker.min.js"></script>
    <script src="theme/manager/assets/plugins/daterangepicker/daterangepicker.js"></script>
    <script type="text/javascript" src="theme/{$settings->theme|escape}/js/apps/orders.js?v=1.04"></script>
    <script type="text/javascript" src="theme/{$settings->theme|escape}/js/apps/order.js?v=1.17"></script>
    <script>
        $(function () {
            $('.js-open-show').hide();

            $('#casual_sms').on('click', function (e) {
                e.preventDefault();

                $('.casual-sms-form').toggle('slow');
            })

            $(document).on('click', '.js-mango-call', function (e) {
                e.preventDefault();

                var _phone = $(this).data('phone');
                var _user = $(this).data('user');
                var _yuk = $(this).hasClass('js-yuk') ? 1 : 0;

                Swal.fire({
                    title: 'Выполнить звонок?',
                    text: "Вы хотите позвонить на номер: " + _phone,
                    type: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    cancelButtonText: 'Отменить',
                    confirmButtonText: 'Да, позвонить'
                }).then((result) => {
                    if (result.value) {

                        $.ajax({
                            url: '/ajax/communications.php',
                            data: {
                                action: 'check',
                                user_id: _user,
                            },
                            success: function (resp) {
                                if (resp == 1) {
                                    $.ajax({
                                        url: 'ajax/mango_call.php',
                                        data: {
                                            phone: _phone,
                                            yuk: _yuk
                                        },
                                        beforeSend: function () {

                                        },
                                        success: function (resp) {
                                            if (!!resp.error) {
                                                if (resp.error == 'empty_mango') {
                                                    Swal.fire(
                                                        'Ошибка!',
                                                        'Необходимо указать Ваш внутренний номер сотрудника Mango-office.',
                                                        'error'
                                                    )
                                                }

                                                if (resp.error == 'empty_mango') {
                                                    Swal.fire(
                                                        'Ошибка!',
                                                        'Не хватает прав на выполнение операции.',
                                                        'error'
                                                    )
                                                }
                                            } else if (resp.success) {
                                                Swal.fire(
                                                    '',
                                                    'Выполняется звонок.',
                                                    'success'
                                                )

                                                $.ajax({
                                                    url: 'ajax/communications.php',
                                                    data: {
                                                        action: 'add',
                                                        user_id: _user,
                                                        type: 'call',
                                                    }
                                                });
                                            } else {
                                                console.error(resp);
                                                Swal.fire(
                                                    'Ошибка!',
                                                    '',
                                                    'error'
                                                )
                                            }
                                        }
                                    })

                                } else {
                                    Swal.fire(
                                        'Ошибка!',
                                        'Исчерпан лимит коммуникаций.',
                                        'error'
                                    )

                                }
                            }
                        })


                    }
                })


            });


            $(document).on('click', '.js-open-contract', function (e) {
                e.preventDefault();
                var _id = $(this).data('id')
                if ($(this).hasClass('open')) {
                    $(this).removeClass('open');
                    $('.js-open-hide.js-dopinfo-' + _id).show();
                    $('.js-open-show.js-dopinfo-' + _id).hide();
                } else {
                    $(this).addClass('open');
                    $('.js-open-hide.js-dopinfo-' + _id).hide();
                    $('.js-open-show.js-dopinfo-' + _id).show();
                }
            })

            $(document).on('change', '.js-contact-status', function () {
                var contact_status = $(this).val();
                var contract_id = $(this).data('contract');
                var user_id = $(this).data('user');
                var $form = $(this).closest('form');

                $.ajax({
                    url: $form.attr('action'),
                    type: 'POST',
                    data: {
                        action: 'contact_status',
                        user_id: user_id,
                        contact_status: contact_status
                    },
                    success: function (resp) {
                        if (contact_status == 1)
                            $('.js-contact-status-block.js-dopinfo-' + contract_id).html('<span class="label label-success">Контактная</span>')
                        else if (contact_status == 2)
                            $('.js-contact-status-block.js-dopinfo-' + contract_id).html('<span class="label label-danger">Не контактная</span>')
                        else if (contact_status == 0)
                            $('.js-contact-status-block.js-dopinfo-' + contract_id).html('<span class="label label-warning">Нет данных</span>')

                    }
                })
            })

            $(document).on('change', '.js-contactperson-status', function () {
                var contact_status = $(this).val();
                var contactperson_id = $(this).data('contactperson');
                var $form = $(this).closest('form');

                $.ajax({
                    url: $form.attr('action'),
                    type: 'POST',
                    data: {
                        action: 'contactperson_status',
                        contactperson_id: contactperson_id,
                        contact_status: contact_status
                    }
                })
            })

            $(document).on('change', '.js-collection-manager', function () {
                var manager_id = $(this).val();
                var contract_id = $(this).data('contract');

                var manager_name = $(this).find('option:selected').text();

                $.ajax({
                    type: 'POST',
                    data: {
                        action: 'collection_manager',
                        manager_id: manager_id,
                        contract_id: contract_id
                    },
                    success: function (resp) {
                        if (manager_id == 0)
                            $('.js-collection-manager-block.js-dopinfo-' + contract_id).html('');
                        else
                            $('.js-collection-manager-block.js-dopinfo-' + contract_id).html(manager_name);
                    }
                })
            })


            $(document).on('click', '.js-open-comment-form', function (e) {
                e.preventDefault();

                if ($(this).hasClass('js-contactperson')) {
                    var contactperson_id = $(this).data('contactperson');
                    $('#modal_add_comment [name=contactperson_id]').val(contactperson_id);
                    $('#modal_add_comment [name=action]').val('contactperson_comment');
                    $('#modal_add_comment [name=order_id]').val($(this).data('order'));
                } else {
                    var contactperson_id = $(this).data('contactperson');
                    $('#modal_add_comment [name=order_id]').val($(this).data('order'));
                    $('#modal_add_comment [name=action]').val('order_comment');
                }


                $('#modal_add_comment [name=text]').text('')
                $('#modal_add_comment').modal();
            });

            $(document).on('click', '.js-open-sms-modal', function (e) {
                e.preventDefault();

                var _user_id = $(this).data('user');
                var _order_id = $(this).data('order');
                var _yuk = $(this).hasClass('is-yuk') ? 1 : 0;

                $('#modal_send_sms [name=user_id]').val(_user_id)
                $('#modal_send_sms [name=order_id]').val(_order_id)
                $('#modal_send_sms [name=yuk]').val(_yuk)
                $('#modal_send_sms').modal();
            });

            $(document).on('submit', '.js-sms-form', function (e) {
                e.preventDefault();

                var $form = $(this);

                var _user_id = $form.find('[name=user_id]').val();

                if ($form.hasClass('loading'))
                    return false;

                $.ajax({
                    url: '/ajax/communications.php',
                    data: {
                        action: 'check',
                        user_id: _user_id,
                    },
                    success: function (resp) {
                        if (!!resp) {
                            $.ajax({
                                type: 'POST',
                                data: $form.serialize(),
                                beforeSend: function () {
                                    $form.addClass('loading')
                                },
                                success: function (resp) {
                                    $form.removeClass('loading');
                                    $('#modal_send_sms').modal('hide');

                                    if (!!resp.error) {
                                        Swal.fire({
                                            timer: 5000,
                                            title: 'Ошибка!',
                                            text: resp.error,
                                            type: 'error',
                                        });
                                    } else {
                                        Swal.fire({
                                            timer: 5000,
                                            title: '',
                                            text: 'Сообщение отправлено',
                                            type: 'success',
                                        });
                                    }
                                },
                            })

                        } else {
                            Swal.fire({
                                title: 'Ошибка!',
                                text: 'Исчерпан лимит коммуникаций',
                                type: 'error',
                            });

                        }
                    }
                })

            });

            $(document).on('change', '.js-workout-input', function () {
                var $this = $(this);

                var _contract = $this.val();
                var _workout = $this.is(':checked') ? 1 : 0;

                $.ajax({
                    type: 'POST',
                    data: {
                        action: 'workout',
                        contract_id: _contract,
                        workout: _workout
                    },
                    beforeSend: function () {
                        $('.jsgrid-load-shader').show();
                        $('.jsgrid-load-panel').show();
                    },
                    success: function (resp) {

                        if (_workout)
                            $this.closest('.js-contract-row').addClass('workout-row');
                        else
                            $this.closest('.js-contract-row').removeClass('workout-row');

                        $('.jsgrid-load-shader').hide();
                        $('.jsgrid-load-panel').hide();

                        /*
                        $.ajax({
                            success: function(resp){
                                $('#basicgrid .jsgrid-grid-body').html($(resp).find('#basicgrid .jsgrid-grid-body').html());
                                $('#basicgrid .jsgrid-header-row').html($(resp).find('#basicgrid .jsgrid-header-row').html());
                                $('.js-period-filter').html($(resp).find('.js-period-filter').html());
                                $('.js-filter-status').html($(resp).find('.js-filter-status').html());
                                $('.js-filter-client').html($(resp).find('.js-filter-client').html());

                                $('.jsgrid-pager-container').html($(resp).find('.jsgrid-pager-container').html());

                                $('.jsgrid-load-shader').hide();
                                $('.jsgrid-load-panel').hide();
                            }
                        });
                        */
                    }
                })

            });


            $(document).on('click', '#check_all', function () {

                if ($(this).is(':checked')) {
                    $('.js-contract-check').each(function () {
                        $(this).prop('checked', true);
                    });
                } else {
                    $('.js-contract-check').each(function () {
                        $(this).prop('checked', false);
                    });
                }
            });

            $(document).on('click', '.js-distribute-open', function (e) {
                e.preventDefault();

                $('.js-distribute-contract').remove();
                $('.js-contract-row').each(function () {
                    $('#form_distribute').append('<input type="hidden" name="contracts[]" class="js-distribute-contract" value="' + $(this).data('contract') + '" />');
                });

                $('.js-select-type').val('all');

                $('#modal_distribute').modal();
            });

            $(document).on('change', '.js-select-type', function () {
                var _current = $(this).val();
                if (_current == 'all') {
                    $('.js-distribute-contract').remove();
                    $('.js-contract-row').each(function () {
                        $('#form_distribute').append('<input type="hidden" name="contracts[]" class="js-distribute-contract" value="' + $(this).data('contract') + '" />');
                    });
                } else if (_current == 'checked') {
                    $('.js-distribute-contract').remove();
                    $('.js-contract-check').each(function () {
                        if ($(this).is(':checked')) {
                            $('#form_distribute').append('<input type="hidden" name="contracts[]" class="js-distribute-contract" value="' + $(this).val() + '" />');
                        }
                    })
                } else if (_current == 'optional') {
                    $('.js-distribute-contract').remove();
                }

            });

            $(document).on('submit', '#form_distribute', function (e) {
                e.preventDefault();

                var $form = $(this);

                if ($form.hasClass('loading'))
                    return false;

                console.log(location.hash)
                var _hash = location.hash.replace('#', '?');
                $.ajax({
                    url: '/my_contracts' + _hash,
                    data: $form.serialize(),
                    type: 'POST',
                    beforeSend: function () {
                        $form.addClass('loading');
                    },
                    success: function (resp) {
                        if (resp.success) {
                            $('#modal_distribute').modal('hide');

                            Swal.fire({
                                timer: 5000,
                                title: 'Договора распределены.',
                                type: 'success',
                            });
//                        location.reload();
                        } else {
                            Swal.fire({
                                text: resp.error,
                                type: 'error',
                            });

                        }
                        $form.removeClass('loading');
                    }
                })
            })

            $(document).on('change', '.js-select-type', function () {
                var _current = $(this).val();

                if (_current == 'optional') {
                    $('.js-input-quantity').fadeIn();
                } else {
                    $('.js-input-quantity').fadeOut();
                }
            });

            $('.download_excel').on('click', function (e) {

                e.preventDefault();

                let link = window.location.href;

                link = link.replace('http://ecozaym24.crm/my_contracts/', '');

                if (link.length < 1)
                    link = location.href + '?download=excel';
                else {
                    link = location.href + '&download=excel';
                    link = link.replace('#', '?');
                }

                location.replace(link);
            });

        })
    </script>
{/capture}

{capture name='page_styles'}
    <link href="theme/{$settings->theme|escape}/assets/plugins/Magnific-Popup-master/dist/magnific-popup.css"
          rel="stylesheet"/>
    <link type="text/css" rel="stylesheet" href="theme/{$settings->theme|escape}/assets/plugins/jsgrid/jsgrid.min.css"/>
    <link type="text/css" rel="stylesheet"
          href="theme/{$settings->theme|escape}/assets/plugins/jsgrid/jsgrid-theme.min.css"/>
    <link href="theme/manager/assets/plugins/bootstrap-datepicker/bootstrap-datepicker.min.css" rel="stylesheet"
          type="text/css"/>
    <!-- Daterange picker plugins css -->
    <link href="theme/manager/assets/plugins/timepicker/bootstrap-timepicker.min.css" rel="stylesheet">
    <link href="theme/manager/assets/plugins/daterangepicker/daterangepicker.css" rel="stylesheet">
    <style>
        .jsgrid-table {
            margin-bottom: 0
        }

        .label {
            white-space: pre;
        }

        .js-open-hide {
            display: block;
        }

        .js-open-show {
            display: none;
        }

        .open.js-open-hide {
            display: none;
        }

        .open.js-open-show {
            display: block;
        }

        .form-control.js-contactperson-status,
        .form-control.js-contact-status {
            font-size: 12px;
            padding-left: 0px;
        }

        .workout-row > td {
            background: #f2f7f8 !important;
        }

        .workout-row a, .workout-row small, .workout-row span {
            color: #555 !important;
            font-weight: 300;
        }
    </style>
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
                <h3 class="text-themecolor mb-0 mt-0"><i class="mdi mdi-animation"></i> Мои договоры</h3>
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="/">Главная</a></li>
                    <li class="breadcrumb-item active">Договоры</li>
                </ol>
            </div>
            <div class="col-md-6 col-4 ">
                <div class="row">
                    <div class="col-6 ">
                        {if in_array($manager->role, ['developer', 'admin', 'senior collector', 'team_collector'])}
                            <div class="float-left">
                                <div class="btn btn-success download_excel">
                                    <i class="fas fa-file-excel"></i> Скачать
                                </div>
                            </div>
                        {/if}
                        {if in_array($manager->role, ['developer', 'admin', 'senior collector', 'team_collector'])}
                            <button class="btn btn-primary js-distribute-open float-right" type="button"><i
                                        class="mdi mdi-account-convert"></i> Распределить
                            </button>
                        {/if}
                    </div>
                </div>
            </div>
        </div>
        <!-- ============================================================== -->
        <!-- End Bread crumb and right sidebar toggle -->
        <!-- ============================================================== -->
        <!-- ============================================================== -->
        <!-- Start Page Content -->
        <!-- ============================================================== -->
        <div class="row">
            <div class="col-12">
                <!-- Column -->
                <div class="card">
                    <div class="card-body">
                        <div class="clearfix">
                            <h4 class="card-title  float-left">Список договоров </h4>
                            {if $manager->role != 'collector'}
                                <div class="float-right js-filter-client">
                                    {foreach $collection_statuses as $cs_id => $cs_name}
                                        <a href="{if $filter_status==$cs_id}{url status=null page=null}{else}{url status=$cs_id page=null}{/if}"
                                           class="btn btn-xs {if $filter_status==$cs_id}btn-success{else}btn-outline-success{/if}">{$cs_name|escape}</a>
                                    {/foreach}
                                </div>
                            {/if}
                        </div>
                        <div id="basicgrid" class="jsgrid" style="position: relative; width: 100%;">
                            <div class="jsgrid-grid-header jsgrid-header-scrollbar">
                            </div>
                            <div class="jsgrid-grid-body">
                                <table class="jsgrid-table table table-striped table-hover">
                                    <tbody>
                                    <tr class="jsgrid-header-row">
                                        <td class="jsgrid-cell">
                                            <div class="custom-checkbox custom-control">
                                                <input type="checkbox" class="custom-control-input" id="check_all"
                                                       value=""/>
                                                <label for="check_all" title="Отметить все"
                                                       class="custom-control-label"> </label>
                                            </div>
                                        </td>

                                        {if in_array($manager->role, ['developer', 'admin', 'chief_collector', 'team_collector'])}
                                            <th
                                                    class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'manager_id_desc'}jsgrid-header-sort jsgrid-header-sort-desc{elseif $sort == 'manager_id_asc'}jsgrid-header-sort jsgrid-header-sort-asc{/if}">
                                                {if $sort == 'manager_id_asc'}<a
                                                    href="{url page=null sort='manager_id_desc'}">Пользователь</a>
                                                {else}<a href="{url page=null sort='manager_id_asc'}">
                                                        Пользователь</a>{/if}
                                            </th>
                                        {/if}

                                        <th
                                                class="jsgrid-header-cell jsgrid-align-right jsgrid-header-sortable {if $sort == 'order_id_desc'}jsgrid-header-sort jsgrid-header-sort-desc{elseif $sort == 'order_id_asc'}jsgrid-header-sort jsgrid-header-sort-asc{/if}">
                                            {if $sort == 'order_id_asc'}<a href="{url page=null sort='order_id_desc'}">
                                                    ID</a>
                                            {else}<a href="{url page=null sort='order_id_asc'}">ID</a>{/if}
                                        </th>

                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'fio_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'fio_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            {if $sort == 'fio_asc'}<a href="{url page=null sort='fio_desc'}">ФИО</a>
                                            {else}<a href="{url page=null sort='fio_asc'}">ФИО</a>{/if}
                                        </th>
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'body_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'body_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            {if $sort == 'body_asc'}<a href="{url page=null sort='body_desc'}">ОД,
                                                руб</a>
                                            {else}<a href="{url page=null sort='body_asc'}">ОД, руб</a>{/if}
                                        </th>
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'percents_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'percents_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            {if $sort == 'percents_asc'}<a href="{url page=null sort='percents_desc'}">
                                                    %, руб</a>
                                            {else}<a href="{url page=null sort='percents_asc'}">%, руб</a>{/if}
                                        </th>
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'total_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'total_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            {if $sort == 'total_asc'}<a href="{url page=null sort='total_desc'}">Итог,
                                                руб</a>
                                            {else}<a href="{url page=null sort='total_asc'}">Итог, руб</a>{/if}
                                        </th>
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'phone_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'phone_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            {if $sort == 'phone_asc'}<a href="{url page=null sort='phone_desc'}">
                                                    Телефон</a>
                                            {else}<a href="{url page=null sort='phone_asc'}">Телефон</a>{/if}
                                        </th>
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'return_asc'}jsgrid-header-sort jsgrid-header-sort-desc{elseif $sort == 'return_desc'}jsgrid-header-sort jsgrid-header-sort-asc{/if}">
                                            {if $sort == 'return_asc'}<a href="{url page=null sort='return_desc'}">
                                                    Просрочен</a>
                                            {else}<a href="{url page=null sort='return_asc'}">Просрочен</a>{/if}
                                        </th>
                                        <!--<th style="width: 80px;"
                                            class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'return_asc'}jsgrid-header-sort jsgrid-header-sort-desc{elseif $sort == 'return_desc'}jsgrid-header-sort jsgrid-header-sort-asc{/if}">
                                            {if $sort == 'return_asc'}<a href="{url page=null sort='return_desc'}">Дата
                                                платежа</a>
                                            {else}<a href="{url page=null sort='return_asc'}">Дата платежа</a>{/if}
                                        </th>-->
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'birth_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'birth_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            Регион
                                        </th>
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'tag_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'tag_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            {if $sort == 'tag_asc'}<a href="{url page=null sort='tag_desc'}">Тег</a>
                                            {else}<a href="{url page=null sort='tag_asc'}">Тег</a>{/if}
                                        </th>
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'birth_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'birth_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            Комментарий
                                        </th>
                                        <!--<th style="width: 140px;"
                                            class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'birth_asc'}jsgrid-header-sort jsgrid-header-sort-asc{elseif $sort == 'birth_desc'}jsgrid-header-sort jsgrid-header-sort-desc{/if}">
                                            Регион
                                        </th>-->
                                        <th
                                                class="jsgrid-header-cell jsgrid-header-sortable {if $sort == 'return_asc'}jsgrid-header-sort jsgrid-header-sort-desc{elseif $sort == 'return_desc'}jsgrid-header-sort jsgrid-header-sort-asc{/if}">
                                            {if $sort == 'return_asc'}<a href="{url page=null sort='return_desc'}">Дата
                                                платежа</a>
                                            {else}<a href="{url page=null sort='return_asc'}">Дата платежа</a>{/if}
                                        </th>
                                    </tr>

                                    <tr class="jsgrid-filter-row" id="search_form">
                                        <td class="jsgrid-cell jsgrid-align-right"></td>

                                        {if in_array($manager->role, ['developer', 'admin', 'chief_collector', 'team_collector'])}
                                            <td class="jsgrid-cell">
                                                <select class="form-control" name="manager_id">
                                                    <option value="0"></option>
                                                    {foreach $managers as $m}
                                                        {if (in_array($manager->role, ['developer', 'admin', 'chief_collector']) && $m->role=='collector') || ($manager->role == 'team_collector' && in_array($m->id, (array)$manager->team_id))}
                                                            <option value="{$m->id}">{$m->name|escape}
                                                                ({$collection_statuses[$m->collection_status_id]})
                                                            </option>
                                                        {/if}
                                                    {/foreach}
                                                </select>
                                            </td>
                                        {/if}

                                        <td class="jsgrid-cell jsgrid-align-right">
                                            <input type="hidden" name="sort" value="{$sort}"/>
                                            <input type="text" name="order_id" value="{$search['order_id']}"
                                                   class="form-control input-sm">
                                        </td>

                                        <td class="jsgrid-cell">
                                            <input type="text" name="fio" value="{$search['fio']}"
                                                   class="form-control input-sm">
                                        </td>
                                        <td class="jsgrid-cell">
                                        </td>
                                        <td class="jsgrid-cell">
                                        </td>
                                        <td class="jsgrid-cell">
                                        </td>
                                        <td class="jsgrid-cell">
                                            <input type="text" name="phone" value="{$search['phone']}"
                                                   class="form-control input-sm">
                                        </td>
                                        <td class="jsgrid-cell">
                                            <div class="row no-gutter">
                                                <div class="col-6 pr-0">
                                                    <input type="text" placeholder="c" name="delay_from"
                                                           value="{$search['delay_from']}"
                                                           class="form-control input-sm">
                                                </div>
                                                <div class="col-6 pl-0">
                                                    <input type="text" name="delay_to" placeholder="по"
                                                           value="{$search['delay_to']}" class="form-control input-sm">
                                                </div>
                                            </div>
                                        </td>
                                        <td class="jsgrid-cell">

                                        </td>
                                        <td class="jsgrid-cell">
                                            <select class="form-control" name="tag_id">
                                                <option value="0"></option>
                                                {foreach $collector_tags as $t}
                                                    <option value="{$t->id}">{$t->name|escape}</option>
                                                {/foreach}
                                            </select>
                                        </td>
                                        <td class="jsgrid-cell">
                                        </td>
                                    </tr>
                                    {foreach $contracts as $contract}
                                        {if !empty($user_risk_op)}
                                            {foreach $user_risk_op as $user}
                                                {if $user->user_id == $contract->order->user_id}
                                                    {foreach $user as $operation => $value}
                                                        {if $value == 1}
                                                            <style>
                                                                .contract-row-{$contract->order->user_id} td {
                                                                    background: rgba(218, 6, 0, 0.4) !important;
                                                                }
                                                            </style>
                                                        {/if}
                                                    {/foreach}
                                                {/if}
                                            {/foreach}
                                        {/if}
                                    {/foreach}
                                    {$shift = ($current_page_num - 1) * $items_per_page}
                                    {$key = 0}
                                    {foreach $contracts as $contract}
                                        {$have_contactperson_search = 0}
                                        {foreach $contract->contactpersons as $cp}
                                            {if $search['phone'] && $search['phone'] != $contract->order->phone_mobile}
                                                {$have_contactperson_search = 1}
                                            {/if}
                                        {/foreach}
                                        <tr class="jsgrid-row js-contract-row {if $contract->collection_workout}workout-row{/if} contract-row-{$contract->order->user_id}"
                                            data-contract="{$contract->id}">
                                            <td class="jsgrid-cell text-center">
                                                <div class="custom-checkbox custom-control">
                                                    <input type="checkbox"
                                                           class="custom-control-input js-contract-check"
                                                           id="contract_{$contract->id}" value="{$contract->id}"/>
                                                    <label for="contract_{$contract->id}"
                                                           class="custom-control-label"> </label>
                                                </div>
                                                {($contract@iteration)+$shift}
                                            </td>


                                            {if in_array($manager->role, ['developer', 'admin', 'chief_collector', 'team_collector'])}
                                                <td class="jsgrid-cell">
                                                    <div class="js-open-hide js-dopinfo-{$contract->id} js-collection-manager-block {if $have_contactperson_search}open{/if}">
                                                        <small>{$managers[$contract->collection_manager_id]->name|escape}</small>
                                                    </div>
                                                    <div class="js-open-show js-dopinfo-{$contract->id}">
                                                        {if $manager->role == 'team_collector'}
                                                            <small>{$managers[$contract->collection_manager_id]->name|escape}</small>
                                                        {else}
                                                            <form action="">
                                                                <select class="form-control js-collection-manager"
                                                                        data-contract="{$contract->id}"
                                                                        name="order_manager[{$contract->collection_manager_id}]">
                                                                    <option value="0"
                                                                            {if !$contract->collection_manager_id}selected{/if}>
                                                                        Не выбран
                                                                    </option>
                                                                    {foreach $managers as $m}
                                                                        {if $m->role == 'collector'}
                                                                            <option value="{$m->id}"
                                                                                    {if $contract->collection_manager_id == $m->id}selected{/if}>{$m->name|escape}</option>
                                                                        {/if}
                                                                    {/foreach}
                                                                </select>
                                                            </form>
                                                        {/if}
                                                    </div>
                                                </td>
                                            {/if}

                                            <td class="jsgrid-cell jsgrid-align-right">
                                                {$contract->order->order_id}
                                            </td>

                                            <td class="jsgrid-cell">
                                                <div>
                                                    <span class="label label-primary">{$collection_statuses[$contract->collection_status]}</span>
                                                </div>
                                                <a href="collector_contract/{$contract->id}">
                                                    {$contract->order->lastname}
                                                    {$contract->order->firstname}
                                                    {$contract->order->patronymic}
                                                </a>
                                                <small>{$contract->order->birth}</small>
                                                {if !empty($user_risk_op)}
                                                {foreach $user_risk_op as $user}
                                                    {if $user->user_id == $contract->order->user_id}
                                                        {foreach $user as $operation => $value}
                                                            {if $value == 1}
                                                                <span class="label label-danger">{$risk_op[$operation]}</span>
                                                            {/if}
                                                        {/foreach}
                                                    {/if}
                                                {/foreach}
                                                {/if}<br>
                                                <small>
                                                    Последний раз заходил(-а):
                                                    {$contract->order->last_activity}
                                                </small>
                                            </td>
                                            <td class="jsgrid-cell">
                                                {$contract->loan_body_summ*1}
                                            </td>
                                            <td class="jsgrid-cell">
                                                {($contract->loan_percents_summ + $contract->loan_charge_summ + $contract->loan_peni_summ) * 1}
                                            </td>
                                            <td class="jsgrid-cell">
                                                <strong>
                                                    {($contract->loan_body_summ + $contract->loan_percents_summ + $contract->loan_charge_summ + $contract->loan_peni_summ) * 1}
                                                </strong>
                                            </td>
                                            <td class="jsgrid-cell">
                                                <div>
                                                    <span class="label {if $contract->client_time_warning == true}label-danger{else}label-success{/if} "><i
                                                                class="far fa-clock"></i> {$contract->user_time}</span>
                                                </div>
                                                {if $search['phone'] && $search['phone'] == $contract->order->phone_mobile}
                                                    <small class="text-danger">{$contract->order->phone_mobile}</small>
                                                {else}
                                                    <small>{$contract->order->phone_mobile}</small>
                                                {/if}
                                            </td>
                                            <td class="jsgrid-cell">
                                                {$contract->delay} {$contract->delay|plural:'день':'дней':'дня'}
                                            </td>
                                            <td style="line-height:1;" class="jsgrid-cell">
                                                {if $contract->order->Regregion == 'ПРИМОРСКИЙ' || $contract->order->Regregion == 'Приморский' || $contract->order->Regregion == 'КРАСНОЯРСКИЙ' || $contract->order->Regregion == 'Красноярский' ||  $contract->order->Regregion == 'ЛЕНИНГРАДСКАЯ'||  $contract->order->Regregion == 'Ленинградская' ||  $contract->order->Regregion == 'САНКТ-ПЕТЕРБУРГ'||  $contract->order->Regregion == 'Санкт-Петербург'}
                                                    <p style="color:#3b0808;font-weight: 800;">{$contract->order->Regregion}</p>
                                                {else}
                                                    <p>{$contract->order->Regregion}</p>
                                                {/if}
                                            </td>
                                            <td class="jsgrid-cell">
                                                <div class="js-open-hide js-dopinfo-{$contract->id} js-contact-status-block">
                                                    {if !$contract->order->contact_status}
                                                        <span class="label label-warning">Нет данных</span>
                                                    {else}
                                                        <span class="label"
                                                              style="background:{$collector_tags[$contract->order->contact_status]->color}">{$collector_tags[$contract->order->contact_status]->name|escape}</span>
                                                    {/if}

                                                    <div class="custom-checkbox mt-1 custom-control">
                                                        <input id="workout_{$contract->id}" type="checkbox"
                                                               class="custom-control-input js-workout-input"
                                                               value="{$contract->id}" name="workout"
                                                               {if $contract->collection_workout}checked="true"{/if} />
                                                        <label for="workout_{$contract->id}"
                                                               class="custom-control-label">
                                                            <small>Отработан</small>
                                                        </label>
                                                    </div>

                                                </div>
                                                <div class="js-open-show js-dopinfo-{$contract->id}">
                                                    <form action="order/{$contract->order->order_id}">
                                                        <select class="form-control js-contact-status"
                                                                data-user="{$contract->order->user_id}"
                                                                data-contract="{$contract->id}"
                                                                name="contact_status[{$contract->order->user_id}]">
                                                            <option value="0"
                                                                    {if !$contract->order->contact_status}selected{/if}>
                                                                Нет данных
                                                            </option>
                                                            {foreach $collector_tags as $t}
                                                                <option value="{$t->id}"
                                                                        {if $contract->order->contact_status == $t->id}selected{/if}>{$t->name|escape}</option>
                                                            {/foreach}
                                                        </select>
                                                    </form>
                                                </div>
                                            </td>

                                            {$comm = $contract->order->comments|first}
                                            <td style="line-height:1;max-width: 300px;
                                            {if $comm->main}
                                                background : #ffd5d5;
                                            {/if}
                                            " class="jsgrid-cell">
                                                <div style="max-height:120px; overflow: auto;">

                                                    {if $comm->official && !$settings->display_only_official_comments}
                                                        <span class="label label-success float-right">Официальный</span>
                                                    {/if}
                                                    <small>{$comm->created}<br> {$comm->text}
                                                        <br><b>{$comm->user_name}</b></small>
                                                </div>
                                            </td>
                                            <td class="jsgrid-cell">
                                                {$contract->return_date|date}
                                            </td>
                                        </tr>
                                    {/foreach}
                                    </tbody>
                                </table>
                            </div>

                            {if $total_pages_num>1}

                                {* Количество выводимых ссылок на страницы *}
                                {$visible_pages = 11}
                                {* По умолчанию начинаем вывод со страницы 1 *}
                                {$page_from = 1}

                                {* Если выбранная пользователем страница дальше середины "окна" - начинаем вывод уже не с первой *}
                                {if $current_page_num > floor($visible_pages/2)}
                                    {$page_from = max(1, $current_page_num-floor($visible_pages/2)-1)}
                                {/if}

                                {* Если выбранная пользователем страница близка к концу навигации - начинаем с "конца-окно" *}
                                {if $current_page_num > $total_pages_num-ceil($visible_pages/2)}
                                    {$page_from = max(1, $total_pages_num-$visible_pages-1)}
                                {/if}

                                {* До какой страницы выводить - выводим всё окно, но не более ощего количества страниц *}
                                {$page_to = min($page_from+$visible_pages, $total_pages_num-1)}
                                <div class="jsgrid-pager-container float-left" style="">
                                    <div class="jsgrid-pager">
                                        Страницы:

                                        {if $current_page_num == 2}
                                            <span class="jsgrid-pager-nav-button "><a
                                                        href="{url page=null}">Пред.</a></span>
                                        {elseif $current_page_num > 2}
                                            <span class="jsgrid-pager-nav-button "><a
                                                        href="{url page=$current_page_num-1}">Пред.</a></span>
                                        {/if}

                                        <span class="jsgrid-pager-page {if $current_page_num==1}jsgrid-pager-current-page{/if}">
                                        {if $current_page_num==1}1{else}<a href="{url page=null}">1</a>{/if}
                                    </span>
                                        {section name=pages loop=$page_to start=$page_from}
                                            {* Номер текущей выводимой страницы *}
                                            {$p = $smarty.section.pages.index+1}
                                            {* Для крайних страниц "окна" выводим троеточие, если окно не возле границы навигации *}
                                            {if ($p == $page_from + 1 && $p != 2) || ($p == $page_to && $p != $total_pages_num-1)}
                                                <span class="jsgrid-pager-page {if $p==$current_page_num}jsgrid-pager-current-page{/if}">
                                            <a href="{url page=$p}">...</a>
                                        </span>
                                            {else}
                                                <span class="jsgrid-pager-page {if $p==$current_page_num}jsgrid-pager-current-page{/if}">
                                            {if $p==$current_page_num}{$p}{else}<a href="{url page=$p}">{$p}</a>{/if}
                                        </span>
                                            {/if}
                                        {/section}
                                        <span class="jsgrid-pager-page {if $current_page_num==$total_pages_num}jsgrid-pager-current-page{/if}">
                                        {if $current_page_num==$total_pages_num}{$total_pages_num}{else}<a
                                            href="{url page=$total_pages_num}">{$total_pages_num}</a>{/if}
                                    </span>

                                        {if $current_page_num<$total_pages_num}
                                            <span class="jsgrid-pager-nav-button"><a
                                                        href="{url page=$current_page_num+1}">След.</a></span>
                                        {/if}
                                        &nbsp;&nbsp; {$current_page_num} из {$total_pages_num}
                                    </div>
                                </div>
                            {/if}


                            <div class="float-right pt-1">
                                <select class="form-control form-control-sm js-page-count" name="page-count">
                                    <option value="{url page_count=50}" {if $page_count==50}selected=""{/if}>Показывать
                                        50
                                    </option>
                                    <option value="{url page_count=100}" {if $page_count==100}selected=""{/if}>
                                        Показывать 100
                                    </option>
                                    <option value="{url page_count=500}" {if $page_count==500}selected=""{/if}>
                                        Показывать 500
                                    </option>
                                    {*}
                                    <option value="{url page_count='all'}" {if $page_count=='all'}selected=""{/if}>Показывать все</option>
                                    {*}
                                </select>
                            </div>

                            <div style="clear:both"></div>

                            <div class="jsgrid-load-shader"
                                 style="display: none; position: absolute; inset: 0px; z-index: 10;">
                            </div>
                            <div class="jsgrid-load-panel"
                                 style="display: none; position: absolute; top: 50%; left: 50%; z-index: 1000;">
                                Идет загрузка...
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Column -->
            </div>
        </div>
        <!-- ============================================================== -->
        <!-- End PAge Content -->
        <!-- ============================================================== -->
    </div>
    <!-- ============================================================== -->
    <!-- End Container fluid  -->
    <!-- ============================================================== -->
    <!-- ============================================================== -->
    <!-- footer -->
    <!-- ============================================================== -->
    {include file='footer.tpl'}
    <!-- ============================================================== -->
    <!-- End footer -->
    <!-- ============================================================== -->
</div>

<div id="modal_add_comment" class="modal fade bd-example-modal-sm" tabindex="-1" role="dialog"
     aria-labelledby="mySmallModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-md">
        <div class="modal-content">

            <div class="modal-header">
                <h4 class="modal-title">Добавить комментарий</h4>
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            </div>
            <div class="modal-body">
                <form method="POST" id="form_add_comment" action="">

                    <input type="hidden" name="order_id" value=""/>
                    <input type="hidden" name="user_id" value=""/>
                    <input type="hidden" name="contactperson_id" value=""/>
                    <input type="hidden" name="action" value=""/>

                    <div class="alert" style="display:none"></div>

                    <div class="form-group">
                        <label for="name" class="control-label">Комментарий:</label>
                        <textarea class="form-control" name="text"></textarea>
                    </div>
                    <div class="custom-control custom-checkbox mr-sm-2 mb-3">
                        <input type="checkbox" name="official" class="custom-control-input" id="official_check"
                               value="1">
                        <label class="custom-control-label" for="official_check">Официальный</label>
                    </div>
                    <div class="form-action">
                        <button type="button" class="btn btn-danger waves-effect" data-dismiss="modal">Отмена</button>
                        <button type="submit" class="btn btn-success waves-effect waves-light">Сохранить</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div id="modal_distribute" class="modal fade bd-example-modal-sm" tabindex="-1" role="dialog"
     aria-labelledby="mySmallModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-md">
        <div class="modal-content">

            <div class="modal-header">
                <h4 class="modal-title">Распределить договора</h4>
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            </div>
            <div class="modal-body">
                <form method="POST" id="form_distribute" action="">

                    <input type="hidden" name="action" value="distribute"/>

                    <div class="alert" style="display:none"></div>

                    <div class="form-group">
                        <select class="form-control js-select-type" name="type">
                            <option value="all">Все видимые</option>
                            <option value="checked">Все отмеченные</option>
                            <option value="optional">Выбрать количество</option>
                        </select>
                        <div class="pt-2">
                            <input class="form-control js-input-quantity" name="quantity" value="" style="display:none"
                                   placeholder="Количество договоров для распределения"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="name" class="control-label"><strong>Менеджеры для распределения:</strong></label>
                        <ul class="list-unstyled" style="max-height:250px;overflow:hidden auto;">
                            {foreach $managers as $m}
                                {if in_array($m->role, ['collector', 'manager']) && !$m->blocked}
                                    <li>
                                        <div class="">
                                            <input class="" name="managers[]" id="distribute_{$m->id}" value="{$m->id}"
                                                   type="checkbox"/>
                                            <label for="distribute_{$m->id}" class="">{$m->name|escape}</label>
                                        </div>
                                    </li>
                                {/if}
                            {/foreach}
                        </ul>
                    </div>
                    <div class="form-action">
                        <button type="button" class="btn btn-danger waves-effect" data-dismiss="modal">Отмена</button>
                        <button type="submit" class="btn btn-success waves-effect waves-light">Распределить</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>