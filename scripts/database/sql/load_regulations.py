#!/usr/bin/env python3
"""
Script to generate SQL INSERT statements for regulations (van_ban) from PDF files in StaticContent/documents
"""

import os
import sys
from pathlib import Path
from datetime import datetime

def get_pdf_files(documents_dir):
    """Get list of PDF files from documents directory"""
    pdf_files = []
    if not os.path.exists(documents_dir):
        print(f"Error: Directory {documents_dir} does not exist", file=sys.stderr)
        return pdf_files
    
    for filename in sorted(os.listdir(documents_dir)):
        if filename.endswith('.pdf') and not filename.startswith('.'):
            pdf_files.append(filename)
    
    return pdf_files

def escape_sql_string(s):
    """Escape single quotes for SQL"""
    return s.replace("'", "''")

def generate_insert_statements(pdf_files):
    """Generate SQL INSERT statements for regulations"""
    sql_statements = []
    
    for filename in pdf_files:
        # Use filename as the document name
        ten_van_ban = filename.replace('.pdf', '')
        url_van_ban = filename  # Just the filename, will be served from /files/
        
        # Try to extract date from filename if possible (format: YYYY-MM-DD)
        ngay_ban_hanh = "NULL"
        # Look for date pattern in filename like "2024-12-25" or "25-12-2024"
        import re
        date_match = re.search(r'(\d{4})[_-](\d{2})[_-](\d{2})', filename)
        if date_match:
            year, month, day = date_match.groups()
            ngay_ban_hanh = f"'{year}-{month}-{day}'"
        
        # Escape quotes
        ten_van_ban_escaped = escape_sql_string(ten_van_ban)
        url_van_ban_escaped = escape_sql_string(url_van_ban)
        
        # Generate INSERT statement
        sql = f"INSERT INTO van_ban (ten_van_ban, url_van_ban, ngay_ban_hanh) VALUES ('{ten_van_ban_escaped}', '{url_van_ban_escaped}', {ngay_ban_hanh}) ON CONFLICT (ten_van_ban) DO UPDATE SET url_van_ban = EXCLUDED.url_van_ban, ngay_ban_hanh = EXCLUDED.ngay_ban_hanh;"
        
        sql_statements.append(sql)
    
    return sql_statements

def main():
    # Get the script directory
    script_dir = Path(__file__).parent
    backend_dir = script_dir.parent.parent.parent / "src" / "backend"
    documents_dir = backend_dir / "StaticContent" / "documents"
    
    # Get PDF files
    pdf_files = get_pdf_files(str(documents_dir))
    
    if not pdf_files:
        print("No PDF files found", file=sys.stderr)
        sys.exit(1)
    
    # Generate SQL statements
    sql_statements = generate_insert_statements(pdf_files)
    
    # Print to stdout
    print("-- Auto-generated SQL script to load regulations from StaticContent/documents")
    print("-- Generated on:", datetime.now().isoformat())
    print()
    
    for sql in sql_statements:
        print(sql)

if __name__ == "__main__":
    main()
