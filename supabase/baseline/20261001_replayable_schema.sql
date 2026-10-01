-- Shavalleya replayable baseline
-- Derived from the verified production contract on 2026-10-01.
create extension if not exists pgcrypto;

create table public.locations(id uuid primary key default gen_random_uuid(),slug text not null unique,name text not null,address text,active boolean not null default true,created_at timestamptz not null default now());
create table public.categories(id uuid primary key default gen_random_uuid(),location_id uuid not null references public.locations(id) on delete cascade,name text not null,sort_order integer not null default 0,active boolean not null default true);
create table public.products(id uuid primary key default gen_random_uuid(),location_id uuid not null references public.locations(id) on delete cascade,category_id uuid references public.categories(id) on delete set null,name text not null,description text,price numeric(10,2) not null check(price>=0),image_url text,available boolean not null default true,sort_order integer not null default 0);
create table public.modifier_groups(id uuid primary key default gen_random_uuid(),location_id uuid not null references public.locations(id) on delete cascade,name text not null,min_select integer not null default 0 check(min_select>=0),max_select integer not null default 1,sort_order integer not null default 0,active boolean not null default true,check(max_select>=min_select));
create table public.modifiers(id uuid primary key default gen_random_uuid(),group_id uuid not null references public.modifier_groups(id) on delete cascade,name text not null,price_delta numeric(10,2) not null default 0,available boolean not null default true,sort_order integer not null default 0);
create table public.product_modifier_groups(product_id uuid not null references public.products(id) on delete cascade,group_id uuid not null references public.modifier_groups(id) on delete cascade,primary key(product_id,group_id));
create table public.orders(id uuid primary key default gen_random_uuid(),location_id uuid not null references public.locations(id),order_number bigint generated always as identity,public_token uuid not null unique default gen_random_uuid(),status text not null default 'pending' check(status in('pending','accepted','preparing','ready','completed','rejected','cancelled')),customer_name text,customer_phone text,notes text,total numeric(10,2) not null check(total>=0),payment_method text not null default 'pickup' check(payment_method='pickup'),created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table public.order_items(id uuid primary key default gen_random_uuid(),order_id uuid not null references public.orders(id) on delete cascade,product_id uuid not null references public.products(id),name_snapshot text not null,unit_price numeric(10,2) not null,quantity integer not null check(quantity>0 and quantity<=20),line_total numeric(10,2) not null);
create table public.order_item_modifiers(id uuid primary key default gen_random_uuid(),order_item_id uuid not null references public.order_items(id) on delete cascade,modifier_id uuid not null references public.modifiers(id),name_snapshot text not null,price_delta numeric(10,2) not null,unique(order_item_id,modifier_id));
create table public.order_status_history(id bigint generated always as identity primary key,order_id uuid not null references public.orders(id) on delete cascade,status text not null,created_at timestamptz not null default now());
create table public.order_notification_outbox(order_id uuid primary key references public.orders(id) on delete cascade,created_at timestamptz not null default now(),delivered_at timestamptz,attempts integer not null default 0,last_error text);

create index idx_categories_location on public.categories(location_id);
create index idx_products_location on public.products(location_id); create index idx_products_category on public.products(category_id);
create index idx_modifier_groups_location on public.modifier_groups(location_id); create index idx_modifiers_group on public.modifiers(group_id);
create index idx_pmg_group on public.product_modifier_groups(group_id); create index idx_orders_location on public.orders(location_id);
create index idx_order_items_order on public.order_items(order_id); create index idx_order_items_product on public.order_items(product_id);
create index idx_oim_order_item on public.order_item_modifiers(order_item_id); create index idx_oim_modifier on public.order_item_modifiers(modifier_id);
create index idx_status_history_order on public.order_status_history(order_id);

alter table public.locations enable row level security; alter table public.categories enable row level security; alter table public.products enable row level security;
alter table public.modifier_groups enable row level security; alter table public.modifiers enable row level security; alter table public.product_modifier_groups enable row level security;
alter table public.orders enable row level security; alter table public.order_items enable row level security; alter table public.order_item_modifiers enable row level security;
alter table public.order_status_history enable row level security; alter table public.order_notification_outbox enable row level security;

create policy "public active locations" on public.locations for select to anon,authenticated using(active);
create policy "public active categories" on public.categories for select to anon,authenticated using(active);
create policy "public available products" on public.products for select to anon,authenticated using(available);
create policy "public active modifier groups" on public.modifier_groups for select to anon,authenticated using(active);
create policy "public available modifiers" on public.modifiers for select to anon,authenticated using(available);
create policy "public product modifier links" on public.product_modifier_groups for select to anon,authenticated using(true);

create or replace function public.get_order_status(p_token uuid) returns jsonb language sql security definer set search_path='public' as $$select jsonb_build_object('order_number',o.order_number,'status',o.status,'total',o.total,'created_at',o.created_at,'updated_at',o.updated_at) from orders o where o.public_token=p_token$$;

create or replace function public.staff_set_order_status(p_order_id uuid,p_status text) returns jsonb language plpgsql security definer set search_path='public' as $$declare v_current text;v_row public.orders%rowtype;begin if auth.role()<>'service_role' then raise exception 'FORBIDDEN';end if;select status into v_current from public.orders where id=p_order_id for update;if v_current is null then raise exception 'ORDER_NOT_FOUND';end if;if p_status<>v_current and not((v_current='pending' and p_status in('accepted','rejected','cancelled'))or(v_current='accepted' and p_status in('preparing','cancelled'))or(v_current='preparing' and p_status in('ready','cancelled'))or(v_current='ready' and p_status in('completed','cancelled')))then raise exception 'INVALID_STATUS_TRANSITION: % -> %',v_current,p_status;end if;if p_status<>v_current then update public.orders set status=p_status,updated_at=now() where id=p_order_id returning * into v_row;insert into public.order_status_history(order_id,status)values(p_order_id,p_status);else select * into v_row from public.orders where id=p_order_id;end if;return jsonb_build_object('id',v_row.id,'status',v_row.status,'updated_at',v_row.updated_at);end$$;

revoke all on function public.staff_set_order_status(uuid,text) from public,anon,authenticated;
grant execute on function public.staff_set_order_status(uuid,text) to service_role;
grant execute on function public.get_order_status(uuid) to anon,authenticated;
