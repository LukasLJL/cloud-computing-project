---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
author: "Me"
tags: ["blog", "tech"]
categories: ["hugo", "blog", "personal"]
description: "This is a description text for {{ replace .Name "-" " " | title }}"
draft: true
ShowToc: true
disableHLJS: false
hideSummary: false
searchHidden: false
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowRssButtonInSectionTermList: true
---