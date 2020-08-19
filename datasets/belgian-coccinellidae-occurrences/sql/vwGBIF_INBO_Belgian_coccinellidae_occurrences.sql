USE [D0017_00_NBNData]
GO

/****** Object:  View [ipt].[vwGBIF_Coccinellidae_occurrences]    Script Date: 19/08/2020 9:04:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








/*

-- ChangeDate : 20130807
-- MOdif : New VagueDatum calculation up closer to Iso Standard

-- ChangeDate : 20150728
-- Modif : adapted to new ipt - release ( BasisOfRecord => controlled vocabulary implementation )
-- Modif 20150908 => Eventdate to Single date ( no range ), range => [verbatimEventDate]
-- 2020 update  add verbatimcoordinates (UTM squares'

*/

ALTER VIEW [ipt].[vwGBIF_Coccinellidae_occurrences]
AS

select 

     [occurrenceID]='INBO:NBN:'+TAO.TAXON_OCCURRENCE_KEY 
	,[modified]=max([inbo].[LCReturnVagueDateGBIF](TD.VAGUE_DATE_START,TD.VAGUE_DATE_END,TD.VAGUE_DATE_TYPE,0)) 
	,[verbatimLocality]=LN.ITEM_NAME
	,basisOfRecord=case
                            when RT.[SHORT_NAME]='None' and ST.SHORT_NAME='field record' then 'HumanObservation'
                            when RT.[SHORT_NAME]='None' and ST.SHORT_NAME<>'fieldObservation' then 'HumanObservation'
                            when RT.[SHORT_NAME]='Collection' then 'PreservedSpecimen'
                               else RT.[SHORT_NAME]
                                 end,InstitutionCode=convert(nvarchar(20),'INBO')  
	
	, [type] = 
		CASE
			WHEN RT.[SHORT_NAME] = 'Collection' THEN N'physicalObject' -- PreservedSpecimen
			WHEN RT.[SHORT_NAME]='None' and ST.SHORT_NAME<>'fieldObservation' then 'event' 
			ELSE N'event'
			end -- HumanObservation
	,OwnerInstitutionCode=case
                                when Charindex('CoccinellidaeWalloonRegiondatabase',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'DEMNA' --'Walloon Region database' 
                                when Charindex('CoccinellidaeFlemishRegionDatabase',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'INBO' --'Flemish Region Database'
                                when Charindex('Coccinellidaeobservations.be',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'Natagora' -- 'observations.be'
                                when Charindex('Coccinellidaewaarnemingen.be',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'Natuurpunt' --'waarnemingen.be'
                                when Charindex('CoccinellidaeWalloonRegiononlineencodingtool',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'DEMNA'
                                else max(convert(varchar(1000),TAO.COMMENT)) --CONVERT(Nvarchar(20),'INBO') 
                                end
	
	,[NBN_SurveyName]=convert(nvarchar(50),S.ITEM_NAME)
	
	,[associatedReferences]=case
                when Charindex('CoccinellidaeWalloonRegiondatabase',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'DEMNA-DFF' --'Walloon Region database' 
                when Charindex('CoccinellidaeFlemishRegionDatabase',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'INBO' --'Flemish Region Database'
                when Charindex('Coccinellidaeobservations.be',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'Natagora' -- 'observations.be'
                when Charindex('Coccinellidaewaarnemingen.be',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'Natuurpunt' --'waarnemingen.be'
                when Charindex('CoccinellidaeWalloonRegiononlineencodingtool',max(convert(varchar(1000),TAO.COMMENT)),1)>0 then 'DEMNA-OFFH'
                else max(convert(varchar(1000),TAO.COMMENT)) --CONVERT(Nvarchar(20),'INBO')  
            end
	,[Language]=convert(nvarchar(20),'Various')  
    ,CatalogNumber=TAO.TAXON_OCCURRENCE_KEY 
      
      -- Taxonomic Elements --
	
	,taxonomicStatus=convert(nvarchar(20),'valid'),originalNameUsage=T.ITEM_NAME,ScientificName=ns.RECOMMENDED_SCIENTIFIC_NAME --recommended scientific soort + genus 
      
	,Kingdom='Animalia'
	,Phylum='Arthropoda'
	,Class='Insecta'
	,[Order]='Coleoptera'
	,Family='Coccinellidae'  
       
	,verbatimTaxonRank=NS.RECOMMENDED_NAME_RANK 
	,taxonRank=NS.RECOMMENDED_NAME_RANK_LONG ---		NULL::text AS InfraSpecificEpithet,
   
	,nomenclaturalCode=convert(nvarchar(20),'ICZN') --tT.TAXN_NAM_WET , -debugging
      -- Identification Elements --
      ---		specimen.identif_qualifier::text AS IdentificationQualifier,
      -- Locality Elements --
      ---		NULL::text AS HigherGeography, 
      ---		NULL::text AS Continent, 
      ---		NULL::text AS WaterBody, 
      ---		NULL::text AS IslandGroup, 
      ---		NULL::text AS Island, 
	,countryCode=convert(nvarchar(20),'BE') ---		NULL::text AS StateProvince, 
    
	,verbatimEventDate=[inbo].[LCReturnVagueDateGBIF](SA.VAGUE_DATE_START,SA.VAGUE_DATE_END,SA.VAGUE_DATE_TYPE,0)  
	,eventDate=[inbo].[LCReturnVagueDateGBIF](SA.VAGUE_DATE_START,SA.VAGUE_DATE_END,SA.VAGUE_DATE_TYPE,0) --CONVERT(Nvarchar(12) , tW.WRNG_BEG_DTE , 120)  + '/' + CONVERT(Nvarchar(12) , tW.WRNG_END_DTE , 120) AS EventDate ,
       
	,individualCount=convert(nvarchar(50),ROUND(sum(convert(float,TAOD.DATA)),0)),LifeStage=dbo.Concatenate(convert(bit,1),case
                                                                                                                                 when TAOD.SHORT_NAME='none' then 'unknown'
                                                                                                                                 when TAOD.SHORT_NAME='Adult' then 'imago'
                                                                                                                                 when TAOD.SHORT_NAME='Ei' then 'egg'
                                                                                                                                 when TAOD.SHORT_NAME='Larve' then 'larva'
                                                                                                                                 when TAOD.SHORT_NAME='Pop' then 'pupa'
                                                                                                                                 else TAOD.SHORT_NAME
                                                                                                                             end+': '+TAOD.DATA,';') ---		NULL::text AS Attributes,
       
	,identifiedBy=coalesce(I.[FORENAME],I.[INITIALS],'')+' '+coalesce(I.[SURNAME],'') ---		specimen.identified_date::text AS DateIdentified, 
      ---		specimen.collection_num::text AS CollectorNumber
	,fieldNotes=case
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,4)=left('KBIN',4) then SPEC.NUMBER
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,5)=left('IRSNB',5) then SPEC.NUMBER
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,14)=left('collectie UGMD',14) then SPEC.NUMBER
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,65)=left('collectie Segers via Michel van Malderen en Victor Naveau (KAVE)',65) then 'collection Segers(KAVE)'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,38)=left('leg. Sébastien Pierret - Marc Pollet',38) then 'leg. Sébastien Pierret - Marc Pollet'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,15)=left('collectie KAVE',15) then 'collection KAVE'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,19)=left('collectie Atalanta',19) then 'collection Atalanta'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,16)=left('collectie Roels',16) then 'collection Roels'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,31)=left('gedetermineerd met Van Goethem',31) then 'Unknown'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,53)=left('aan voet van zeeduin, gedetermineerd met Van Goethem',53) then 'Unknown'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,20)=left('Dieren in collectie',20) then 'collection'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,82)=left('verschillende exx aanwezig aan de beek, 1 ex in collectie, gegevens via JP Beuckx',82) then 'Unknown'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,59)=left('collectie Deledicque; determinaties gebeurd door JP Beuckx',59) then 'collection Deledicque'
                        when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,24)=left('Collectie Pletinck René',24) then 'Collection Pletinck René'
                        else null --SUBSTRING (MAX(LTRIM(CONVERT(Varchar(2000),TAO.COMMENT))), MAX(CHARINDEX(' || ', LTRIM(CONVERT(Varchar(2000),TAO.COMMENT)),1))+4,50 )
                        
                    end --TAO.SURVEYORS_REF
                    ---		coalesce(specimen.label,'')::text AS FieldNumber, 
/**	,FieldNotes=case
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,4)=left('KBIN',4) then convert(varchar(max),SPEC.COMMENT)
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,5)=left('IRSNB',5) then convert(varchar(max),SPEC.COMMENT)
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,14)=left('collectie UGMD',14) then convert(varchar(max),SPEC.COMMENT)
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,65)=left('collectie Segers via Michel van Malderen en Victor Naveau (KAVE)',65) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,38)=left('leg. Sébastien Pierret - Marc Pollet;',38) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,15)=left('collectie KAVE',15) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,19)=left('collectie Atalanta',19) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,16)=left('collectie Roels',16) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,31)=left('gedetermineerd met Van Goethem',31) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,53)=left('aan voet van zeeduin, gedetermineerd met Van Goethem',53) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,20)=left('Dieren in collectie',20) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,82)=left('verschillende exx aanwezig aan de beek, 1 ex in collectie, gegevens via JP Beuckx',82) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,59)=left('collectie Deledicque; determinaties gebeurd door JP Beuckx',59) then 'Unknown'
						when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,24)=left('Collectie Pletinck René',24) then 'Unknown'
						else null --SUBSTRING (MAX(LTRIM(CONVERT(Varchar(2000),TAO.COMMENT))), MAX(CHARINDEX(' || ', LTRIM(CONVERT(Varchar(2000),TAO.COMMENT)),1))+4,50 )
	                    
					end **/
	, CollectionCode=case
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,4)=left('KBIN',4) then 'RBINS Collection'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,5)=left('IRSNB',5) then 'RBINS Collection'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,14)=left('collectie UGMD',14) then 'UGMD Collection'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,65)=left('collectie Segers via Michel van Malderen en Victor Naveau (KAVE)',65) then 'KAVE'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,38)=left('leg. Sébastien Pierret - Marc Pollet;',38) then 'Private collection Pierret'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,15)=left('collectie KAVE',15) then 'KAVE'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,19)=left('collectie Atalanta',19) then 'Private collection Verbeke'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,16)=left('collectie Roels',16) then 'Private collection Roels'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,31)=left('gedetermineerd met Van Goethem',31) then 'Private collection Troukens'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,53)=left('aan voet van zeeduin, gedetermineerd met Van Goethem',53) then 'Private collection Troukens'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,20)=left('Dieren in collectie',20) then 'Private collection Van de Kerckhove'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,82)=left('verschillende exx aanwezig aan de beek, 1 ex in collectie, gegevens via JP Beuckx',82) then 'Private collection Deledicque'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,59)=left('collectie Deledicque; determinaties gebeurd door JP Beuckx',59) then 'Private collection Deledicque'
                       when max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))>0 and SUBSTRING(max(LTRIM(convert(varchar(2000),TAO.COMMENT))),max(CHARINDEX(' || ',LTRIM(convert(varchar(2000),TAO.COMMENT)),1))+4,24)=left('Collectie Pletinck René',24) then 'Private collection Pletinck René'
                       else null --SUBSTRING (MAX(LTRIM(CONVERT(Varchar(2000),TAO.COMMENT))), MAX(CHARINDEX(' || ', LTRIM(CONVERT(Varchar(2000),TAO.COMMENT)),1))+4,50 )
                       
                   end 
	,OtherCatalogNumbers=  'OriginalDatasetIDReference : ' + CASE	
					WHEN CHARINDEX(' || ', MAX(CONVERT(Varchar(2000),TAO.COMMENT))) > 0 THEN SUBSTRING(MAX(CONVERT(Varchar(2000),TAO.COMMENT)),6,CHARINDEX('||', MAX(CONVERT(Varchar(2000),TAO.COMMENT)))-6 )
					ELSE SUBSTRING(MAX(CONVERT(Varchar(2000),TAO.COMMENT)),6,1000)
				END +
				COALESCE ('; SpecimenLocation : ' + SPEC.LOCATION ,'')
                                                   -- Geospatial Extension --
      --CONVERT(Nvarchar(20),convert(decimal(12,3),round(SA.[LAT],3)) )AS DecimalLatitude, -> Org coordinates
      --CONVERT(Nvarchar(20),convert(decimal(12,3),round(SA.[LONG],3)) )AS DecimalLongitude, -> org coordinates
    ,DecimalLatitude=case
                           when SA.SPATIAL_REF_QUALIFIER in('Centroïd UTM 100m','Centroïd UTM 1km','centroïd UTM 5km','Centroïd UTM 10km') then convert(nvarchar(20),convert(decimal(12,3),round(coalesce(SA.[LAT],0),3)))
                           when SA.SPATIAL_REF_QUALIFIER='XY from original rec' then convert(nvarchar(20),convert(decimal(12,3),round(coalesce(SA.[LAT],0),3)))
                           else null
                       end
	,DecimalLongitude=case
                                                when SA.SPATIAL_REF_QUALIFIER in('Centroïd UTM 100m','Centroïd UTM 1km','centroïd UTM 5km','Centroïd UTM 10km') then convert(nvarchar(20),convert(decimal(12,3),round(coalesce(SA.[LONG],0),3)))
                                                when SA.SPATIAL_REF_QUALIFIER='XY from original rec' then convert(nvarchar(20),convert(decimal(12,3),round(coalesce(SA.[LONG],0),3)))
                                                else null
                                            end 
	,GeodeticDatum=convert(nvarchar(10),'WGS84')  
    ,verbatimCoordinateSystem = convert(nvarchar(10),'BD72')
    ,CoordinateUncertaintyInMeters=convert(nvarchar(5),coalesce(case
                                                                      when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 100m' then '70.71'
                                                                      when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 1km' then '707.1'
                                                                      when SA.SPATIAL_REF_QUALIFIER='centroïd UTM 5km' then '3536'
                                                                      when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 10km' then '7071'
                                                                      when SA.SPATIAL_REF_QUALIFIER='XY from original rec' then SDAP.DATA
                                                                      else null
                                                                  end,'70.71')) --		, Preciesie = SDAP.DATA 		
     , [verbatimCoordinates] = SDA.DATA

     ,associatedTaxa=dbo.Concatenate(convert(bit,1),RELT.SHORT_NAME+': '+T2.ITEM_NAME,';'),samplingProtocol=case
                                                                                                                 when ST.SHORT_NAME='Bac' then 'pitfall trap'
                                                                                                                 when ST.SHORT_NAME='Field Observation' then 'field observation'
                                                                                                                 when ST.SHORT_NAME='Klopvangst' then 'beating tray'
                                                                                                                 when ST.SHORT_NAME='Licht(val)' then 'light trap'
                                                                                                                 when ST.SHORT_NAME='Lijmband' then 'yellow sticky trap'
                                                                                                                 when ST.SHORT_NAME='Malaise Trap' then 'malaise trap'
                                                                                                                 when ST.SHORT_NAME='Net' then 'insect net'
                                                                                                                 when ST.SHORT_NAME='Pitfall Trap' then 'pitfall Trap'
                                                                                                                 when ST.SHORT_NAME='Sleepstaal' then 'sweepnetting'
                                                                                                                 when ST.SHORT_NAME='Zeven' then 'sieving'
                                                                                                                 else 'Unknown'
                                                                                                             end 

	, [licence] = CONVERT(Nvarchar(50), 'http://creativecommons.org/publicdomain/zero/1.0/')
	, [accessRights] = CONVERT(Nvarchar(50), 'http://www.inbo.be/en/norms-for-data-use') 
	, [DatasetID] = CONVERT(Nvarchar(100),'http://dataset.inbo.be/belgiancoccinellidae-occurrences')
	, [DatasetName]= 'Belgian Coccinellidae - Ladybird occurrences'
	

from dbo.Survey S
    inner join [dbo].[Survey_event] SE on SE.[Survey_Key]=S.[Survey_Key]
    left join [dbo].[Location] L on L.[Location_Key]=SE.[Location_key]
    left join [dbo].[Location_Name] LN on LN.[Location_Key]=L.[Location_Key]
    inner join [dbo].[SAMPLE] SA on SA.[SURVEY_EVENT_KEY]=SE.[SURVEY_EVENT_KEY]
    left join [dbo].[SAMPLE_TYPE] ST on ST.[SAMPLE_TYPE_KEY]=SA.[SAMPLE_TYPE_KEY]
    inner join [dbo].[TAXON_OCCURRENCE] TAO on TAO.[SAMPLE_KEY]=SA.[SAMPLE_KEY]
    left join [dbo].[RECORD_TYPE] RT on RT.[RECORD_TYPE_KEY]=TAO.[RECORD_TYPE_KEY]
    left join [dbo].[SPECIMEN] SP on SP.[TAXON_OCCURRENCE_KEY]=TAO.[TAXON_OCCURRENCE_KEY]
    left join [dbo].[TAXON_DETERMINATION] TD on TD.[TAXON_OCCURRENCE_KEY]=TAO.[TAXON_OCCURRENCE_KEY]
    left join [dbo].[INDIVIDUAL] I on I.[NAME_KEY]=TD.[DETERMINER]
    left join [dbo].[DETERMINATION_TYPE] DT on DT.[DETERMINATION_TYPE_KEY]=TD.[DETERMINATION_TYPE_KEY] --Taxon
                                               
    left join [dbo].[TAXON_LIST_ITEM] TLI on TLI.[TAXON_LIST_ITEM_KEY]=TD.[TAXON_LIST_ITEM_KEY]
    left join [dbo].[TAXON_VERSION] TV on TV.[TAXON_VERSION_KEY]=TLI.[TAXON_VERSION_KEY]
    left join [dbo].[TAXON] T on T.[TAXON_KEY]=TV.[TAXON_KEY]
    inner join [dbo].[TAXON_LIST_VERSION] TLV on TLV.[TAXON_LIST_VERSION_KEY]=TLI.[TAXON_LIST_VERSION_KEY]
    inner join [dbo].[TAXON_LIST] TL on TL.[TAXON_LIST_KEY]=TLV.[TAXON_LIST_KEY]
    inner join [dbo].[TAXON_RANK] TR on TR.TAXON_RANK_KEY=TLI.TAXON_RANK_KEY --Normalizeren Namen 
                                        --LEFT JOIN [dbo].[NAMESERVER] NS ON NS.INPUT_TAXON_VERSION_KEY = TD.TAXON_LIST_ITEM_KEY
                                        
    inner join [inbo].[NameServer_12] NS on NS.[INBO_TAXON_VERSION_KEY]=TLI.[TAXON_VERSION_KEY] -->Common name nog opzoeken...
                                            --Recorders
                                            
    left join [dbo].[SAMPLE_RECORDER] SR on SR.[SAMPLE_KEY]=SA.[SAMPLE_KEY] --UTM-hok
                                            
    inner join [dbo].[SAMPLE_DATA] SDA on SDA.[SAMPLE_KEY]=SA.[SAMPLE_KEY]
    left join(select SDAP.*
              from [dbo].[SAMPLE_DATA] SDAP
                   inner join [dbo].[MEASUREMENT_QUALIFIER] MQP on MQP.[MEASUREMENT_QUALIFIER_KEY]=SDAP.[MEASUREMENT_QUALIFIER_KEY]
              where MQP.[LONG_NAME]='Locatiebepaling') SDAP on SDAP.[SAMPLE_KEY]=SA.[SAMPLE_KEY]
    inner join [dbo].[MEASUREMENT_QUALIFIER] MQ on MQ.[MEASUREMENT_QUALIFIER_KEY]=SDA.[MEASUREMENT_QUALIFIER_KEY]
    inner join [dbo].[MEASUREMENT_UNIT] MU on MU.[MEASUREMENT_UNIT_KEY]=SDA.[MEASUREMENT_UNIT_KEY]
    inner join [dbo].[MEASUREMENT_TYPE] MT on MT.[MEASUREMENT_TYPE_KEY]=MQ.[MEASUREMENT_TYPE_KEY] and MT.[MEASUREMENT_TYPE_KEY]=MU.[MEASUREMENT_TYPE_KEY]
    left join(select TAOD.*,MQ.SHORT_NAME
              from [dbo].[TAXON_OCCURRENCE_DATA] TAOD
                   inner join [dbo].[MEASUREMENT_QUALIFIER] MQ on MQ.MEASUREMENT_QUALIFIER_KEY=TAOD.MEASUREMENT_QUALIFIER_KEY) TAOD on TAOD.TAXON_OCCURRENCE_KEY=TAO.TAXON_OCCURRENCE_KEY
    left join [dbo].[SPECIMEN] SPEC on SPEC.TAXON_OCCURRENCE_KEY=TAO.TAXON_OCCURRENCE_KEY --Associated Occurrence
                                       
    left join [dbo].[TAXON_OCCURRENCE_RELATION] TOR on TOR.[TAXON_OCCURRENCE_KEY_1]=TAO.[TAXON_OCCURRENCE_KEY]
    left join [dbo].[TAXON_OCCURRENCE] TAO2 on TAO2.TAXON_OCCURRENCE_KEY=TOR.TAXON_OCCURRENCE_KEY_2
    left join [dbo].[TAXON_DETERMINATION] TD2 on TD2.[TAXON_OCCURRENCE_KEY]=TAO2.[TAXON_OCCURRENCE_KEY]
    left join [dbo].[RELATIONSHIP_TYPE] RELT on RELT.RELATIONSHIP_TYPE_KEY=TOR.RELATIONSHIP_TYPE_KEY --Associated Taxa
                                                
    left join [dbo].[TAXON_LIST_ITEM] TLI2 on TLI2.[TAXON_LIST_ITEM_KEY]=TD2.[TAXON_LIST_ITEM_KEY]
    left join [dbo].[TAXON_VERSION] TV2 on TV2.[TAXON_VERSION_KEY]=TLI2.[TAXON_VERSION_KEY]
    left join [dbo].[TAXON] T2 on T2.[TAXON_KEY]=TV2.[TAXON_KEY]
where S.[ITEM_NAME]='Coccinellidae of Belgium' 
and LN.PREFERRED=1 
and TD.[PREFERRED]=1 
and NS.[RECOMMENDED_NAME_RANK] not in('FunGp','Agg','SppGrp') 
and DT.[SHORT_NAME] not in('Incorrect','Invalid','Considered Incorrect','Requires Confirmation') 
and TR.[SEQUENCE]>=230 
and MT.SHORT_NAME='Code' 
and MQ.LONG_NAME='UTMhok' 
and TAO.CONFIDENTIAL=0 
and SA.LAT is not null and SA.LONG is not null and TL.TAXON_LIST_KEY in('INBSYS0000000035','BFN0017900005N6D') 
     
group by TAO.[TAXON_OCCURRENCE_KEY],LN.[ITEM_NAME],RT.[SHORT_NAME],convert(nvarchar(50),S.[ITEM_NAME]),T.[ITEM_NAME],NS.[RECOMMENDED_SCIENTIFIC_NAME],NS.[RECOMMENDED_NAME_RANK],NS.[RECOMMENDED_NAME_RANK_LONG],RT.[SHORT_NAME],SA.[VAGUE_DATE_START],SA.[VAGUE_DATE_END],SA.[VAGUE_DATE_TYPE],SA.[SAMPLE_KEY],SDA.DATA,SDAP.DATA,coalesce(I.[FORENAME],I.[INITIALS],'')+' '+coalesce(I.[SURNAME],''),convert(nvarchar(20),convert(decimal(12,3),round(coalesce(SA.LAT,0),3))),convert(nvarchar(20),convert(decimal(12,3),round(coalesce(SA.LONG,0),3))),SA.SPATIAL_REF_SYSTEM,SA.SPATIAL_REF_QUALIFIER,TAOD.SHORT_NAME,TAO.SURVEYORS_REF,SPEC.NUMBER,SPEC.LOCATION,convert(varchar(max),SPEC.COMMENT),TAOD.DATA,ST.SHORT_NAME --ORDER BY SDAP.DATA ;
        







GO


