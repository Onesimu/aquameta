/*******************************************************************************
 * endpoint - client
 *
 * Created by Aquameta Labs, an open source company in Portland Oregon, USA.
 * Company: http://aquameta.com/
 * Project: http://blog.aquameta.com/
 ******************************************************************************/

begin;

set search_path=endpoint;



/*******************************************************************************
*
*
* ENDPOINT CLIENT
*
*
*******************************************************************************/

/*******************************************************************************
* table remote_endpoint, a known endpoint out in the universe
*******************************************************************************/
create table remote_endpoint (
    id uuid default public.uuid_generate_v4() primary key,
    url text
);


/*******************************************************************************
* rows_select
*******************************************************************************/
create or replace function endpoint.client_rows_select(remote_endpoint_id uuid, relation_id meta.relation_id, args json, out response http_client.http_response)
as $$

select http_client.http_get (
    (select url from endpoint.remote_endpoint where id=remote_endpoint_id)
        || '/' || http_client.urlencode((relation_id.schema_id).name)
        || '/relation'
        || '/' || http_client.urlencode(relation_id.name)
        || '/rows'
);

$$ language sql;


/*******************************************************************************
* row_select
*******************************************************************************/
create or replace function endpoint.client_row_select(remote_endpoint_id uuid, row_id meta.row_id, out response http_client.http_response)
as $$

select http_client.http_get (
    (select url from endpoint.remote_endpoint where id=remote_endpoint_id)
        || '/' || (row_id::meta.schema_id).name
        || '/table'
        || '/' || (row_id::meta.relation_id).name
        || '/row'
        || '/' || row_id.pk_value
);

$$ language sql;


/*******************************************************************************
* field_select
*******************************************************************************/
/*
create or replace function endpoint.client_field_select(remote_endpoint_id uuid, field_id meta.field_id) returns text
as $$

select http_client.http_get (
    (select url from endpoint.remote_endpoint where id=remote_endpoint_id)
        || '/' || (field_id::meta.schema_id).name
        || '/table'
        || '/' || (field_id::meta.relation_id).name
        || '/row'
        || '/' || (field_id.row_id).pk_value
        || '/' || (field_id.column_id).name
);

$$ language sql;
*/


/*******************************************************************************
* row_delete
*******************************************************************************/
/*
create or replace function endpoint.client_row_delete(remote_endpoint_id uuid, row_id meta.row_id) returns text
as $$

select http_client.http_delete (
    (select url from endpoint.remote_endpoint where id=remote_endpoint_id)
        || '/' || (row_id::meta.schema_id).name
        || '/table'
        || '/' || (row_id::meta.relation_id).name
        || '/row'
        || '/' || row_id.pk_value
);

$$ language sql;
*/




/*******************************************************************************
* rows_select_function
*******************************************************************************/
create or replace function endpoint.client_rows_select_function(remote_endpoint_id uuid, function_id meta.function_id, arg_vals text[], out http_client.http_response)
as $$
declare
    qs text;
begin

select http_client.http_get (
    (select url from endpoint.remote_endpoint where id=remote_endpoint_id)
        || '/' || (function_id).schema_id.name
        || '/function'
        || '/' || (function_id).name
        || '/rows'
        || '?' || endpoint.array_to_querystring((function_id).parameters, arg_vals)
);

end;
$$ language plpgsql;



/*******************************************************************************
* rows_insert
*******************************************************************************/
/*
create or replace function endpoint.client_rows_insert(remote_endpoint_id uuid, args json, out response http_client.http_response)
as $$
begin

    -- TOOD: fixme
select http_client.http_post (
    (select url || '/insert' from endpoint.remote_endpoint where id=remote_endpoint_id),
    args::text -- fixme?  does a post expect x=7&y=p&z=3 ?
);
end;
$$ language plpgsql;
*/


--
--
-- row_insert(remote_id uuid, relation_id meta.relation_id, row_object json)
-- row_update(remote_id uuid, row_id meta.row_id, args json)
--
-- rows_select(remote_id uuid, relation_id meta.relation_id, args json)
--
--
--

commit;