#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Steps
-----
0. initialize table
1. read through the files
2. extract pmid and doi
3. write to sql database


"""
import pubmed_parser as pp
import os
import time
import gzip
from lxml import etree


#ftp://ftp.ncbi.nlm.nih.gov/pubmed/baseline

root_path = "/Volumes/Pubmed/Pubmed/"
root_path = "/Users/jim/Desktop/"



class Book(Base):
    __tablename__ = "book"
    book_id = Column(Integer, primary_key=True)
    author_id = Column(Integer, ForeignKey("author.author_id"))
    title = Column(String)
    publishers = relationship(
        "Publisher", secondary=book_publisher, back_populates="books"
    )





#year 2021 -> 21
prefix = 'pubmed21n'
suffix = '.xml.gz'

value = 100
int_string = '%04d' % (value)
file_path = root_path + prefix + int_string + suffix






t1 = time.time()
dicts_out = pp.parse_medline_xml(file_path,
                                 year_info_only=False,
                                 nlm_category=False,
                                 author_list=False,
                                 reference_list=False)

t2 = time.time()
print(t2-t1)
#32 seconds ...
#43 seconds for 100


# open and read gzipped xml file

"""
t1 = time.time()
with gzip.open(file_path, 'rb') as f:
    file_string = f.read()
    t2 = time.time()
    tree = etree.fromstring(file_string)
t3 = time.time()
print(t2-t1)
print(t3-t2)
"""

t1 = time.time()
tree = etree.parse(file_path)

#TODO: What's the DTD? link to it here ...
#http://dtd.nlm.nih.gov/ncbi/pubmed/out/pubmed_190101.dtd

t2 = time.time()
print(t2-t1)


"""
	<Item Name="ArticleIds" Type="List">
		<Item Name="pubmed" Type="String">32022941</Item>
		<Item Name="doi" Type="String">10.1002/nau.24300</Item>
		<Item Name="rid" Type="String">32022941</Item>
		<Item Name="eid" Type="String">32022941</Item>
"""

#<PMID Version="1">1</PMID>
#ArticleIdList
#<ArticleIdList>
#    <ArticleId IdType="pubmed">101</ArticleId>
#</ArticleIdList>

#PubmedArticleSet
#  - PubmedArticle

#Quicker to iterate with while next than findall?


t3 = time.time()
article = tree.find('PubmedArticle')
printed = False
mapping = {}
while article is not None:
    article_ids = article.find('PubmedData/ArticleIdList')
    try:
        doi = article_ids.find('ArticleId[@IdType="doi"]')
        pmid = article_ids.find('ArticleId[@IdType="pubmed"]')
        mapping[int(pmid.text)] = doi.text
    except:
        pmid = article.find('MedlineCitation/PMID')
        mapping[int(pmid.text)] = ''
        if article_ids is None:
            #Get pubmed id the other way, not sure where this is ...
            pass
        pass
    article = article.getnext()
        
        
t4 = time.time()
print(t4-t3)






t2 = time.time()
pa = tree.findall("//PubmedArticle")
t3 = time.time()
print(t3-t2)
t3 = time.time()
printed = False
mapping = {}
for article in pa:
    article_ids = article.find('PubmedData/ArticleIdList')
    try:
        doi = article_ids.find('ArticleId[@IdType="doi"]')
        pmid = article_ids.find('ArticleId[@IdType="pubmed"]')
        mapping[int(pmid.text)] = doi.text
    except:
        #<MedlineCitation Status="MEDLINE" Owner="NLM">
        #   <PMID Version="1">3024134</PMID>
        pmid = article.find('MedlineCitation/PMID')
        mapping[int(pmid.text)] = ''
        if article_ids is None:
            #Get pubmed id the other way, not sure where this is ...
            pass
        pass
        
        
t4 = time.time()
print(t4-t3)
