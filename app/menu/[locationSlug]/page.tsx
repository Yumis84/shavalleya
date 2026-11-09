import MenuClient from './MenuClient'
import type { Category, Location, Product } from '@/lib/types'

export function generateStaticParams(){
  return [{ locationSlug: 'kashtanovaya-73a' }]
}

type MenuData={location:Location;categories:Category[];products:Product[]}

async function supabaseGet<T>(path:string):Promise<T>{
  const url=process.env.NEXT_PUBLIC_SUPABASE_URL
  const key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY
  if(!url||!key) throw new Error('Supabase build configuration is missing')
  const response=await fetch(`${url}/rest/v1/${path}`,{
    headers:{apikey:key,Authorization:`Bearer ${key}`},
    cache:'no-store',
  })
  if(!response.ok) throw new Error(`Menu build request failed: ${response.status}`)
  return response.json() as Promise<T>
}

async function loadMenu(locationSlug:string):Promise<MenuData>{
  const locations=await supabaseGet<Location[]>(`locations?select=*&slug=eq.${encodeURIComponent(locationSlug)}&active=eq.true&limit=1`)
  const location=locations[0]
  if(!location) throw new Error(`Active location not found: ${locationSlug}`)
  const id=encodeURIComponent(location.id)
  const [categories,products]=await Promise.all([
    supabaseGet<Category[]>(`categories?select=*&location_id=eq.${id}&active=eq.true&order=sort_order.asc`),
    supabaseGet<Product[]>(`products?select=*&location_id=eq.${id}&available=eq.true&order=sort_order.asc`),
  ])
  return {location,categories,products}
}

export default async function MenuPage({params}:{params:Promise<{locationSlug:string}>}){
  const {locationSlug}=await params
  const menu=await loadMenu(locationSlug)
  return <MenuClient initialLocation={menu.location} initialCategories={menu.categories} initialProducts={menu.products}/>
}
